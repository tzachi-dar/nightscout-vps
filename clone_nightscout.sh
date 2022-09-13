clone_collection() {
   REST_ENDPOINT=$1
   collection_name=$2
   echo $REST_ENDPOINT
   if [[ $collection_name == entries ]]; then
       wget $REST_ENDPOINT/api/v1/$collection_name'.json?find[date][$gte]=1662845659&count=1000000' -O $collection_name.json 
   else
       wget $REST_ENDPOINT/api/v1/$collection_name'.json?find[created_at][$gte]=1662845659&count=1000000' -O $collection_name.json
   fi
   jq '.[]' $collection_name.json > $collection_name.jq.json 
   mongoimport --uri "mongodb://username:password@localhost:27017/Nightscout" --collection=$collection_name --file=$collection_name.jq.json

}
for collection in entries activity devicestatus food profile treatments;
do echo "<$collection>"; 
clone_collection $1  $collection
done