from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models.user import User
from models.farm import Farm
from models.tree import Tree
from models.fruit import Fruit
from schemas import FarmDashboard, TreeDashboard
from auth_utils import get_current_user

router = APIRouter()


@router.get("/{farm_id}", response_model=FarmDashboard)
def get_dashboard(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    trees = db.query(Tree).filter(Tree.farm_id == farm_id).all()

    tree_summaries = []
    total_active_fruits = 0

    for tree in trees:
        active_fruits = (
            db.query(Fruit)
            .filter(Fruit.tree_id == tree.id, Fruit.is_harvested == False)
            .all()
        )

        fruit_count = len(active_fruits)
        total_active_fruits += fruit_count

        earliest_harvest = (
            min((f.harvest_date for f in active_fruits), default=None)
        )

        dominant_stage = None
        if active_fruits:
            stage_counts = {}
            for f in active_fruits:
                stage_counts[f.growth_stage] = stage_counts.get(f.growth_stage, 0) + 1
            dominant_stage = max(stage_counts, key=stage_counts.get)

        tree_summaries.append(TreeDashboard(
            tree_number=tree.tree_number,
            gps_lat=float(tree.gps_lat) if tree.gps_lat else None,
            gps_lng=float(tree.gps_lng) if tree.gps_lng else None,
            fruit_count=fruit_count,
            earliest_harvest_date=earliest_harvest,
            growth_stage=dominant_stage,
        ))

    return FarmDashboard(
        farm_id=farm.id,
        farm_name=farm.name,
        total_trees=len(trees),
        total_active_fruits=total_active_fruits,
        trees=tree_summaries,
    )
