from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.farm import Farm
from models.order import Order
from models.testimonial import Testimonial
from auth_utils import get_current_user
from schemas import TestimonialCreate, TestimonialUpdate, TestimonialResponse

router = APIRouter()


@router.get("/{farm_id}/reviews", response_model=list[TestimonialResponse])
def list_reviews(
    farm_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user),
):
    if not db.query(Farm).filter(Farm.id == farm_id, Farm.is_public == True).first():
        raise HTTPException(status_code=404, detail="Farm not found")
    return (
        db.query(Testimonial)
        .filter(Testimonial.farm_id == farm_id)
        .order_by(Testimonial.created_at.desc())
        .all()
    )


@router.get("/{farm_id}/reviews/mine", response_model=TestimonialResponse)
def get_my_review(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    t = db.query(Testimonial).filter(
        Testimonial.farm_id == farm_id,
        Testimonial.buyer_id == current_user.id,
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="No review found")
    return t


@router.post("/{farm_id}/reviews", response_model=TestimonialResponse, status_code=status.HTTP_201_CREATED)
def create_review(
    farm_id: int,
    body: TestimonialCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not db.query(Farm).filter(Farm.id == farm_id, Farm.is_public == True).first():
        raise HTTPException(status_code=404, detail="Farm not found")

    eligible = db.query(Order).filter(
        Order.farm_id == farm_id,
        Order.buyer_id == current_user.id,
        Order.status == "delivered",
        Order.billplz_paid == True,
    ).first()
    if not eligible:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only review farms where you have a completed and paid order",
        )

    if db.query(Testimonial).filter(
        Testimonial.farm_id == farm_id,
        Testimonial.buyer_id == current_user.id,
    ).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="You have already reviewed this farm")

    t = Testimonial(farm_id=farm_id, buyer_id=current_user.id, rating=body.rating, comment=body.comment)
    db.add(t)
    db.commit()
    db.refresh(t)
    return t


@router.patch("/{farm_id}/reviews/{review_id}", response_model=TestimonialResponse)
def update_review(
    farm_id: int,
    review_id: int,
    body: TestimonialUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    t = db.query(Testimonial).filter(
        Testimonial.id == review_id,
        Testimonial.farm_id == farm_id,
        Testimonial.buyer_id == current_user.id,
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="Review not found")

    if body.rating is not None:
        t.rating = body.rating
    if body.comment is not None:
        t.comment = body.comment
    t.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(t)
    return t


@router.delete("/{farm_id}/reviews/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_review(
    farm_id: int,
    review_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    t = db.query(Testimonial).filter(
        Testimonial.id == review_id,
        Testimonial.farm_id == farm_id,
        Testimonial.buyer_id == current_user.id,
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="Review not found")
    db.delete(t)
    db.commit()
