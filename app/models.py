from app import db, login
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from hashlib import md5


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), index=True, unique=True)
    email = db.Column(db.String(120), index=True, unique=True)
    password_hash = db.Column(db.String(128))
    posts = db.relationship('Post', backref='author', lazy='dynamic')
    about_me = db.Column(db.String(140))
    last_seen = db.Column(db.DateTime, default=datetime.utcnow)
    inquiries = db.relationship('PolicyInquiry',
                                backref='inquirer',
                                lazy='dynamic')
    policies = db.relationship('PolicyAgreement',
                               backref='holder',
                               lazy='dynamic')

    def __repr__(self):
        return '<User {}>'.format(self.username)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def avatar(self, size):
        digest = md5(self.email.lower().encode('utf-8')).hexdigest()
        r = 'https://www.gravatar.com/avatar/{}?d=identicon&s={}'
        return r.format(digest, size)


class Insurer(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), index=True, unique=True)
    policies = db.relationship('PolicyAgreement',
                               backref='insurer',
                               lazy='dynamic')

    def __repr__(self):
        return '<Insurer {}>'.format(self.name)


class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    body = db.Column(db.String(140))
    timestamp = db.Column(db.String(140))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Post {}>'.format(self.body)


class PolicyInquiry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    risk = db.Column(db.String(140))
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    zip_code = db.Column(db.Integer)
    limit = db.Column(db.Float)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    offers = db.relationship('PolicyOffer', backref='inquiry', lazy='dynamic')

    def __repr__(self):
        return '<Inquiry {}, {}, {}, {}>'.format(self.timestamp,
                                                 self.risk,
                                                 self.zip_code,
                                                 self.limit)


class PolicyOffer(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    risk = db.Column(db.String(140))
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    premium = db.Column(db.Float)
    limit = db.Column(db.Float)
    inquiry_id = db.Column(db.Integer, db.ForeignKey('policy_inquiry.id'))

    def __repr__(self):
        return '<Offer {}, {}, {}, {}>'.format(self.timestamp,
                                               self.risk,
                                               self.premium,
                                               self.limit)


class PolicyAgreement(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    insurer_id = db.Column(db.Integer, db.ForeignKey('insurer.id'))
    offer_id = db.Column(db.Integer, db.ForeignKey('policy_offer.id'))
    inquiry_id = db.Column(db.Integer, db.ForeignKey('policy_inquiry.id'))


@login.user_loader
def load_user(id):
    return User.query.get(int(id))
