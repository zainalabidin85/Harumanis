from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models.user import User
from models.farm import Farm, GrowthPhase
from models.tree import Tree
from models.fruit import Fruit
from schemas import DoaYieldReport, DoaFarmSummary, DoaStageCount, DoaVerifyOwnerRequest
from auth_utils import require_doa
from services.fruit_lifecycle import auto_abort_stale_fruits

router = APIRouter()


@router.get("/yield-report", response_model=DoaYieldReport)
def get_yield_report(
    season: Optional[int] = Query(None, description="Calendar year to report on; defaults to the current season"),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_doa),
):
    auto_abort_stale_fruits(db)

    current_season = season or datetime.now().year
    available_seasons = sorted(
        (row[0] for row in db.query(Fruit.season).distinct().all()),
        reverse=True,
    )
    stage_labels = {p.stage: p.label for p in db.query(GrowthPhase).all()}

    farms = [f for f in db.query(Farm).all() if not f.owner.is_suspended]

    stage_summary: dict[int, int] = {}
    total_trees = 0
    total_active_fruits = 0
    total_harvested_fruits = 0
    total_aborted_fruits = 0
    total_farms = 0
    farm_summaries: list[DoaFarmSummary] = []

    for farm in farms:
        is_counted = farm.owner.is_verified

        tree_count = db.query(func.count(Tree.id)).filter(Tree.farm_id == farm.id).scalar()

        active_fruits = (
            db.query(Fruit)
            .join(Tree, Fruit.tree_id == Tree.id)
            .filter(
                Tree.farm_id == farm.id,
                Fruit.season == current_season,
                Fruit.is_harvested == False,
                Fruit.is_aborted == False,
            )
            .all()
        )

        farm_stage_counts: dict[int, int] = {}
        for fruit in active_fruits:
            farm_stage_counts[fruit.growth_stage] = farm_stage_counts.get(fruit.growth_stage, 0) + 1

        harvested_count = (
            db.query(func.count(Fruit.id))
            .join(Tree, Fruit.tree_id == Tree.id)
            .filter(Tree.farm_id == farm.id, Fruit.season == current_season, Fruit.is_harvested == True)
            .scalar()
        )
        aborted_count = (
            db.query(func.count(Fruit.id))
            .join(Tree, Fruit.tree_id == Tree.id)
            .filter(Tree.farm_id == farm.id, Fruit.season == current_season, Fruit.is_aborted == True)
            .scalar()
        )

        if is_counted:
            total_farms += 1
            total_trees += tree_count
            total_active_fruits += len(active_fruits)
            total_harvested_fruits += harvested_count
            total_aborted_fruits += aborted_count
            for stage, count in farm_stage_counts.items():
                stage_summary[stage] = stage_summary.get(stage, 0) + count

        farm_summaries.append(DoaFarmSummary(
            farm_id=farm.id,
            farm_name=farm.name,
            location=farm.location,
            owner_id=farm.owner.id,
            owner_name=farm.owner.name,
            owner_phone=farm.owner.phone,
            is_verified=is_counted,
            total_trees=tree_count,
            active_fruits=len(active_fruits),
            harvested_fruits=harvested_count,
            aborted_fruits=aborted_count,
            stage_counts=[
                DoaStageCount(stage=stage, label=stage_labels.get(stage, f"Stage {stage}"), count=count)
                for stage, count in sorted(farm_stage_counts.items())
            ],
        ))

    return DoaYieldReport(
        current_season=current_season,
        available_seasons=available_seasons,
        total_farms=total_farms,
        total_trees=total_trees,
        total_active_fruits=total_active_fruits,
        total_harvested_fruits=total_harvested_fruits,
        total_aborted_fruits=total_aborted_fruits,
        stage_summary=[
            DoaStageCount(stage=stage, label=stage_labels.get(stage, f"Stage {stage}"), count=count)
            for stage, count in sorted(stage_summary.items())
        ],
        farms=farm_summaries,
    )


@router.patch("/owners/{owner_id}/verify")
def set_owner_verified(
    owner_id: int,
    payload: DoaVerifyOwnerRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_doa),
):
    owner = db.query(User).filter(User.id == owner_id).first()
    if owner is None:
        raise HTTPException(status_code=404, detail="Farm owner not found")
    if owner.is_suspended:
        raise HTTPException(status_code=400, detail="Cannot verify a suspended owner")

    owner.is_verified = payload.is_verified
    db.commit()
    return {"owner_id": owner.id, "is_verified": owner.is_verified}
