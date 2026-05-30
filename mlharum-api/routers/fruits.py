from datetime import datetime, date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.tree import Tree
from models.fruit import Fruit
from auth_utils import get_current_user
from schemas import ActiveFruitResponse, FruitAbortRequest

router = APIRouter()


def _to_response(fruit: Fruit) -> ActiveFruitResponse:
    days_to_harvest = max(0, (fruit.harvest_date - date.today()).days)
    return ActiveFruitResponse(
        id=fruit.id,
        label=fruit.label,
        size_cm=float(fruit.size_cm),
        growth_stage=fruit.growth_stage,
        harvest_date=fruit.harvest_date,
        days_to_harvest=days_to_harvest,
        is_harvested=fruit.is_harvested,
        is_aborted=fruit.is_aborted,
        abort_reason=fruit.abort_reason,
        created_at=fruit.created_at,
    )


def _get_owned_tree(tree_id: int, user: User, db: Session) -> Tree:
    tree = (
        db.query(Tree)
        .join(Tree.farm)
        .filter(Tree.id == tree_id, Tree.farm.has(user_id=user.id))
        .first()
    )
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    return tree


def _get_owned_fruit(fruit_id: int, user: User, db: Session) -> Fruit:
    fruit = (
        db.query(Fruit)
        .join(Fruit.tree)
        .join(Tree.farm)
        .filter(Fruit.id == fruit_id, Tree.farm.has(user_id=user.id))
        .first()
    )
    if not fruit:
        raise HTTPException(status_code=404, detail="Fruit not found")
    return fruit


@router.get("/{tree_id}/fruits", response_model=list[ActiveFruitResponse])
def list_active_fruits(
    tree_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _get_owned_tree(tree_id, current_user, db)
    fruits = (
        db.query(Fruit)
        .filter(
            Fruit.tree_id == tree_id,
            Fruit.is_harvested == False,
            Fruit.is_aborted == False,
        )
        .order_by(Fruit.harvest_date.asc())
        .all()
    )
    return [_to_response(f) for f in fruits]


@router.patch("/{fruit_id}/harvest", response_model=ActiveFruitResponse)
def mark_harvested(
    fruit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    fruit = _get_owned_fruit(fruit_id, current_user, db)
    if fruit.is_aborted:
        raise HTTPException(status_code=400, detail="Fruit is already marked as aborted")
    if fruit.is_harvested:
        raise HTTPException(status_code=400, detail="Fruit is already marked as harvested")
    fruit.is_harvested = True
    fruit.harvested_at = datetime.utcnow()
    db.commit()
    db.refresh(fruit)
    return _to_response(fruit)


@router.patch("/{fruit_id}/abort", response_model=ActiveFruitResponse)
def mark_aborted(
    fruit_id: int,
    payload: FruitAbortRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    fruit = _get_owned_fruit(fruit_id, current_user, db)
    if fruit.is_harvested:
        raise HTTPException(status_code=400, detail="Fruit is already marked as harvested")
    if fruit.is_aborted:
        raise HTTPException(status_code=400, detail="Fruit is already marked as aborted")
    fruit.is_aborted = True
    fruit.abort_reason = payload.reason
    fruit.aborted_at = datetime.utcnow()
    db.commit()
    db.refresh(fruit)
    return _to_response(fruit)
