from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from models import File, FileItem, Tag, FileWithTag, FileWithAuthor, Author


class DBManager():
    def __init__(self):
        self.engine = create_engine(
            "sqlite:///C:\\Users\\34284\\Documents\\书籍\\.config\\db.sqlite", echo=True)
        self.session = Session(self.engine)


db = DBManager()
