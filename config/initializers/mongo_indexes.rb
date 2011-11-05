MONGO_INDEX_ASC  = 1
MONGO_INDEX_DESC = -1

Comment.ensure_index([[:rid, MONGO_INDEX_ASC]])
Comment.ensure_index([[:lid, MONGO_INDEX_ASC]])

Ranking.ensure_index({:nid => MONGO_INDEX_ASC, :uid => MONGO_INDEX_ASC})
Ranking.ensure_index({:uid => MONGO_INDEX_ASC, :v => MONGO_INDEX_ASC})

RankingAverage.ensure_index([[:nid, MONGO_INDEX_ASC]])

Recommend.ensure_index([[:uid, MONGO_INDEX_ASC]])
Recommend.ensure_index([[:to_uid, MONGO_INDEX_ASC]])
Recommend.ensure_index([[:lid, MONGO_INDEX_ASC]])

Detail.ensure_index([[:r, MONGO_INDEX_ASC]])

