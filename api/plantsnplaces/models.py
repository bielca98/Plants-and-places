from werkzeug.security import generate_password_hash, check_password_hash
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(256), nullable=False)
    plants = db.relationship('PlantLocation', backref='user', lazy=True)

    def __repr__(self):
        return f'<User {self.username}>'

    def set_password(self, password):
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

    def save(self):
        if not self.id:
            db.session.add(self)
        db.session.commit()

    @staticmethod
    def get_by_username(username):
        return User.query.filter_by(username=username).first()


class Plant(db.Model):
    name = db.Column(db.String(80), primary_key=True)

    def __repr__(self):
        return f'<Plant {self.name}>'

    def save(self):
        db.session.add(self)

    def create(self):
        db.session.commit()

    @staticmethod
    def get_by_name(name):
        return Plant.query.filter_by(name=name).first()


class PlantLocation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_username = db.Column(db.String(80), db.ForeignKey('user.username'),
                              nullable=False)
    plant_name = db.Column(db.String(80), db.ForeignKey('plant.name'),
                              nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    image_path = db.Column(db.String(400))

    def __repr__(self):
        return f'<PlantLocation {self.id}>'

    def save(self):
        if not self.id:
            db.session.add(self)
        db.session.commit()
