from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.farm import Farm
from models.tree import Tree
from schemas import FarmCreate, FarmResponse, TreeBulkCreate, TreeResponse
from auth_utils import get_current_user

router = APIRouter()


@router.post("", response_model=FarmResponse, status_code=status.HTTP_201_CREATED)
def create_farm(
    payload: FarmCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = Farm(**payload.model_dump(), user_id=current_user.id)
    db.add(farm)
    db.commit()
    db.refresh(farm)
    return farm


@router.get("/{farm_id}", response_model=FarmResponse)
def get_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    return farm


@router.post("/{farm_id}/trees", response_model=list[TreeResponse], status_code=status.HTTP_201_CREATED)
def create_trees(
    farm_id: int,
    payload: TreeBulkCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    trees = [Tree(farm_id=farm_id, **t.model_dump()) for t in payload.trees]
    db.add_all(trees)
    farm.total_trees = db.query(Tree).filter(Tree.farm_id == farm_id).count() + len(trees)
    db.commit()
    for tree in trees:
        db.refresh(tree)
    return trees


@router.get("/{farm_id}/trees", response_model=list[TreeResponse])
def list_trees(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    return db.query(Tree).filter(Tree.farm_id == farm_id).all()
