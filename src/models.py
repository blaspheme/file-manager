from typing import List
from typing import Optional
from sqlalchemy import ForeignKey
from sqlalchemy import String, DateTime, Column
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime


class Base(DeclarativeBase):
    pass


class File(Base):
    __tablename__ = "file"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    isbn: Mapped[Optional[str]]
    publisher: Mapped[Optional[str]]  # 出版社
    publish_date: Mapped[Optional[str]]  # 出版日期
    rank: Mapped[Optional[int]]  # 评级
    items: Mapped[List["FileItem"]] = relationship(
        back_populates="items", cascade="all, delete-orphan"
    )
    fileWithTags: Mapped[List["FileWithTag"]] = relationship(
        back_populates="fileWithTags", cascade="all, delete-orphan"
    )
    fileWithAuthors: Mapped[List["FileWithAuthor"]] = relationship(
        back_populates="fileWithAuthors", cascade="all, delete-orphan"
    )  # 作者
    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())

    def __repr__(self) -> str:
        return f"File(id={self.id!r}, name={self.name!r}, isbn={self.isbn!r})"


class FileItem(Base):
    __tablename__ = "file_item"
    id: Mapped[int] = mapped_column(primary_key=True)
    path: Mapped[str]  # 做完HASH的名称
    file_type: Mapped[Optional[str]]  # 文件类型
    file_id: Mapped[int] = mapped_column(ForeignKey("file.id"))
    items: Mapped["File"] = relationship(back_populates="items")
    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())

    def __repr__(self) -> str:
        return f"FileItem(id={self.id!r}, path={self.path!r})"


class Tag(Base):
    __tablename__ = "tag"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    tagWithFiles: Mapped[List["FileWithTag"]] = relationship(
        back_populates="tagWithFiles", cascade="all, delete-orphan"
    )
    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())

    def __repr__(self) -> str:
        return f"Tag(id={self.id!r}, name={self.name!r})"


class FileWithTag(Base):
    __tablename__ = "file_with_tag"
    id: Mapped[int] = mapped_column(primary_key=True)
    file_id: Mapped[int] = mapped_column(ForeignKey("file.id"))
    fileWithTags: Mapped["File"] = relationship(back_populates="fileWithTags")
    tag_id: Mapped[int] = mapped_column(ForeignKey("tag.id"))
    tagWithFiles: Mapped["Tag"] = relationship(back_populates="tagWithFiles")
    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())


class Author(Base):
    __tablename__ = "author"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]  # 名字
    remark: Mapped[Optional[str]]  # 备注
    authorWithFiles: Mapped[List["FileWithAuthor"]] = relationship(
        back_populates="authorWithFiles", cascade="all, delete-orphan"
    )
    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())

    def __repr__(self) -> str:
        return f"Author(id={self.id!r}, name={self.path!r})"


class FileWithAuthor(Base):
    __tablename__ = "file_with_author"
    id: Mapped[int] = mapped_column(primary_key=True)
    file_id: Mapped[int] = mapped_column(ForeignKey("file.id"))
    fileWithAuthors: Mapped["File"] = relationship(
        back_populates="fileWithAuthors")

    author_id: Mapped[int] = mapped_column(ForeignKey("author.id"))
    authorWithFiles: Mapped["Author"] = relationship(
        back_populates="authorWithFiles")

    created_at = Column(DateTime, default=datetime.utcnow())
    updated_at = Column(DateTime, default=datetime.utcnow())


# 测试代码
if __name__ == '__main__':
    # 初始化数据库连接:
    engine = create_engine(
        "sqlite:///C:\\Users\\34284\\Documents\\书籍\\.config\\db.sqlite", echo=True)

    # CREATE TABLE DDL
    Base.metadata.create_all(engine)

    # 测试数据
    from sqlalchemy.orm import Session

    with Session(engine) as session:
        spongebob = File(
            name="spongebob",
            isbn="Spongebob Squarepants",
            items=[FileItem(path="spongebob@sqlalchemy.org")],
            fileWithTags=[
                FileWithTag(
                    tagWithFiles=Tag(name="sss")
                ),
                FileWithTag(
                    tagWithFiles=Tag(name="aaa")
                )
            ],
            created_at=datetime.utcnow()
        )
        sandy = File(
            name="sandy",
            isbn="Sandy Cheeks",
            items=[
                FileItem(path="sandy@sqlalchemy.org"),
                FileItem(path="sandy@squirrelpower.org"),
            ],
            fileWithAuthors=[
                FileWithAuthor(
                    authorWithFiles=Author(name='张三')
                )
            ]
        )
        patrick = File(name="patrick", isbn="Patrick Star")
        session.add_all([spongebob, sandy, patrick])
        session.commit()
