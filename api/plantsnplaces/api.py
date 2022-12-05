import os
import jwt
import datetime
from werkzeug.utils import secure_filename
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, current_app
)
from flask_jwt_extended import (create_access_token, create_refresh_token,
                                jwt_required, get_jwt_identity)
from .models import User, Plant, PlantLocation

bp = Blueprint('api', __name__, url_prefix='/api/v1')

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', }


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


"""
    AUTH ENDPOINTS
"""


@bp.route('/auth/signup/', methods=('POST', ))
def signup():
    request_data = request.get_json()

    if request_data is None:
        return {'status': 'Bad request', 'error': 'Missing fields.'}, 400

    missing_fields = [field for field in
                      ['username', 'password1', 'password2']
                      if field not in request_data]

    if len(missing_fields) > 0:
        return {
            'status': 'Bad request',
            'error': 'Missing fields: ' + ', '.join(missing_fields) + '.'
        }, 400

    if request_data['password1'] != request_data['password2']:
        return {
            'status': 'Bad request',
            'error': 'Passwords don\'t match.'
        }, 400

    user = User(username=request_data['username'])

    if User.get_by_username(user.username) is not None:
        return {
            'status': 'Ok',
            'error': 'The username is taken.'
        }, 200

    user.set_password(request_data['password1'])
    user.save()

    return {'status': 'Created'}, 201


@bp.route('/auth/login/', methods=('POST', ))
def login():
    request_data = request.get_json()

    if request_data is None:
        return {'status': 'Bad request', 'error': 'Missing fields.'}, 400
    missing_fields = [field for field in
                      ['username', 'password']
                      if field not in request_data]

    if len(missing_fields) > 0:
        return {
            'status': 'Bad request',
            'error': 'Missing fields: ' + ', '.join(missing_fields) + '.'
        }, 400

    user = User.get_by_username(request_data['username'])

    if user is None or not user.check_password(request_data['password']):
        return {
            'status': 'Ok',
            'error': 'Invalid user or password.'
        }, 200

    access_token = create_access_token(identity=request_data['username'])
    refresh_token = create_refresh_token(identity=request_data['username'])

    return {
        'status': 'Ok',
        'access_token': access_token,
        'refresh_token': refresh_token
    }, 200


@bp.route('/auth/refresh-token/', methods=('POST', ))
@jwt_required(refresh=True)
def refresh_token():
    identity = get_jwt_identity()
    access_token = create_access_token(identity=identity)
    return {'status': 'Ok', 'access_token': access_token}


"""
    PLANTS ENDPOINTS
"""


@bp.route('/plants/', methods=('GET', ))
def plant_locations_list():
    plant_locations = PlantLocation.query.all()

    return {
        "data": [{
            "user": plant.user_username,
            "plant": plant.plant_name,
            "latitude": plant.latitude,
            "longitude": plant.longitude,
            "image_path": plant.image_path,
        } for plant in plant_locations],
        "status": "Ok",
    }


@bp.route('/plants/<username>/', methods=('GET', ))
def plant_locations_list_username(username):
    plant_locations = PlantLocation.query.filter_by(user_username=username)

    if plant_locations.count() == 0:
        return {
            "status": "Not found"
        }, 404

    return {
        "data": [{
            "user": plant.user_username,
            "plant": plant.plant_name,
            "latitude": plant.latitude,
            "longitude": plant.longitude,
            "image_path": plant.image_path,
        } for plant in plant_locations],
        "status": "Ok",
    }


@bp.route('/plants/create/', methods=('POST', ))
@jwt_required()
def plant_locations_create():
    if request.form is None:
        return {'status': 'Bad request', 'error': 'Missing fields.'}, 400

    missing_fields = [field for field in
                      ['plant', 'latitude', 'longitude']
                      if field not in request.form]

    if len(missing_fields) > 0:
        return {
            'status': 'Bad request',
            'error': 'Missing fields: ' + ', '.join(missing_fields)
        }, 400

    plant = Plant.get_by_name(request.form['plant'])

    if plant is None:
        plant = Plant(name=request.form['plant'])
        plant.create()

    image_path = None

    if 'image' in request.files:
        file = request.files['image']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            return {'status': 'Bad request', 'error': 'File not selected.'}, 400
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(current_app.config['MEDIA_PATH'], filename))
            image_path = current_app.config['MEDIA_URL'] + filename
        else:
            return {'status': 'Bad request', 'error': 'Invalid file.'}, 400

    username = get_jwt_identity()
    plant_location = PlantLocation(
        user_username=username,
        plant_name=plant.name,
        latitude=request.form['latitude'],
        longitude=request.form['longitude'],
        image_path=image_path
    )
    plant_location.save()

    return {'status': 'Created'}, 201
