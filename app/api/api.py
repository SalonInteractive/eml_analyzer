from fastapi import APIRouter

from app.api.endpoints import analyze, submit

api_router = APIRouter()
api_router.include_router(analyze.router, prefix="/analyze", tags=["analyze"])
# api_router.include_router(submit.router, prefix="/submit", tags=["submit"])
