from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session
from database import get_db
from models.farm import Farm
from models.tree import Tree
from models.fruit import Fruit
from models.user import User
from models.testimonial import Testimonial
from auth_utils import get_current_user
from schemas import MarketplaceFarmSummary, MarketplaceFarmDetail, TreeDashboard, FarmImageResponse
from routers.farm_images import _image_url, _thumb_url

router = APIRouter()


def _build_farm_summary(farm: Farm, db: Session) -> dict:
    fruits = (
        db.query(Fruit)
        .join(Tree, Fruit.tree_id == Tree.id)
        .filter(Tree.farm_id == farm.id, Fruit.is_harvested == False, Fruit.is_aborted == False)
        .all()
    )

    stage_counts = {1: 0, 2: 0, 3: 0}
    earliest: date | None = None
    for f in fruits:
        if f.growth_stage in stage_counts:
            stage_counts[f.growth_stage] += 1
        if f.harvest_date:
            if earliest is None or f.harvest_date < earliest:
                earliest = f.harvest_date

    review_stats = db.query(
        func.avg(Testimonial.rating).label("avg_rating"),
        func.count(Testimonial.id).label("review_count"),
    ).filter(Testimonial.farm_id == farm.id).first()

    return {
        "farm_id": farm.id,
        "farm_name": farm.name,
        "location": farm.location,
        "gps_lat": float(farm.gps_lat) if farm.gps_lat else None,
        "gps_lng": float(farm.gps_lng) if farm.gps_lng else None,
        "farmer_name": farm.owner.name,
        "farmer_verified": farm.owner.is_verified,
        "price_per_kg": float(farm.price_per_kg) if farm.price_per_kg else None,
        "ready_in_days": farm.ready_in_days if farm.ready_in_days is not None else 4,
        "thumbnail_url": _image_url(farm.images[0].filename) if farm.images else None,
        "total_active_fruits": len(fruits),
        "stage_1_count": stage_counts[1],
        "stage_2_count": stage_counts[2],
        "stage_3_count": stage_counts[3],
        "earliest_harvest_date": earliest,
        "avg_rating": round(float(review_stats.avg_rating), 1) if review_stats.avg_rating else None,
        "review_count": review_stats.review_count or 0,
    }


@router.get("", response_model=list[MarketplaceFarmSummary])
def list_public_farms(db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    farms = db.query(Farm).filter(Farm.is_public == True).all()
    return [_build_farm_summary(f, db) for f in farms]


@router.get("/{farm_id}", response_model=MarketplaceFarmDetail)
def get_public_farm(farm_id: int, db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.is_public == True).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found or not publicly listed")

    summary = _build_farm_summary(farm, db)

    trees = db.query(Tree).filter(Tree.farm_id == farm_id).all()
    tree_data = []
    for tree in trees:
        active_fruits = [f for f in tree.fruits if not f.is_harvested and not f.is_aborted]
        harvest_dates = [f.harvest_date for f in active_fruits if f.harvest_date]
        stages = [f.growth_stage for f in active_fruits if f.growth_stage]
        tree_data.append(TreeDashboard(
            tree_number=tree.tree_number,
            gps_lat=float(tree.gps_lat) if tree.gps_lat else None,
            gps_lng=float(tree.gps_lng) if tree.gps_lng else None,
            fruit_count=len(active_fruits),
            earliest_harvest_date=min(harvest_dates) if harvest_dates else None,
            growth_stage=max(set(stages), key=stages.count) if stages else None,
        ))

    summary["trees"] = tree_data
    summary["images"] = [
        FarmImageResponse(
            id=img.id,
            farm_id=img.farm_id,
            url=_image_url(img.filename),
            thumb_url=_thumb_url(img.filename),
            caption=img.caption,
            uploaded_at=img.uploaded_at,
        )
        for img in farm.images
    ]
    return summary
