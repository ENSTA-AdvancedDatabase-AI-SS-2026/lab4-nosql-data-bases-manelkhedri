
# ex2_sessions.py

import redis
import uuid

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

SESSION_TTL = 1800  # 30 minutes


# Créer session
def create_session(user_id):
    session_id = str(uuid.uuid4())

    key = f"session:{session_id}"

    r.setex(key, SESSION_TTL, user_id)

    return session_id


# Vérifier session
# Sliding expiration

def validate_session(session_id):
    key = f"session:{session_id}"

    user_id = r.get(key)

    if user_id:
        r.expire(key, SESSION_TTL)
        return user_id

    return None

# Supprimer session

def delete_session(session_id):
    key = f"session:{session_id}"
    r.delete(key)


