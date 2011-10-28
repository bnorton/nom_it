MONGO_INDEX_ASC  = 1
MONGO_INDEX_DESC = -1

Comment.ensure_index({:rid => MONGO_INDEX_ASC})
Comment.ensure_index({:lid => MONGO_INDEX_ASC})

Rating.ensure_index({})

RatingAverage.ensure_index({:nid => MONGO_INDEX_ASC})

Recommend.ensure_index({:uid    => MONGO_INDEX_ASC})
Recommend.ensure_index({:to_uid => MONGO_INDEX_ASC})
Recommend.ensure_index({:lid    => MONGO_INDEX_ASC})

Like.ensure_index({})
