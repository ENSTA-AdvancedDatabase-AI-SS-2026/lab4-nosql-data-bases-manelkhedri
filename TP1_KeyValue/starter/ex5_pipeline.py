import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Pipeline bulk insert

def bulk_insert_products(products):

    pipe = r.pipeline()

    for product in products:

        key = f"product:{product['id']}"

        pipe.hset(key, mapping=product)

    pipe.execute()

# Transaction atomique

def place_order(user_id, product_id, quantity):

    product_key = f"stock:{product_id}"
    cart_key = f"cart:{user_id}"

    with r.pipeline() as pipe:

        while True:
            try:

                pipe.watch(product_key)

                stock = pipe.get(product_key)

                stock = int(stock) if stock else 0

                if stock < quantity:
                    pipe.unwatch()
                    return "Stock insuffisant"

                pipe.multi()

                pipe.decrby(product_key, quantity)
                pipe.hset(cart_key, product_id, quantity)

                pipe.execute()

                return "Commande validée"

            except redis.WatchError:
                continue
