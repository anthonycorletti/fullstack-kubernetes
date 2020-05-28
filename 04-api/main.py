from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import v1_router

api = FastAPI(docs_url="/api/docs",
              redoc_url="/api/redoc",
              openapi_url="/api/openapi.json")

api.add_middleware(CORSMiddleware,
                   allow_origins=["*"],
                   allow_methods=["*"],
                   allow_headers=["*"],
                   expose_headers=["*"])

api.include_router(
    v1_router.router,
    prefix="/api/v1",
    tags=["v1"],
)
