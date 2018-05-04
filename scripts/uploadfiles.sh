for i in $(cat ./k8s-version-diff.txt |grep -v v0. |awk -F '"' '{print $4}')
do
  curl --request POST --header 'PRIVATE-TOKEN: b******************k' --data "content=$(./get-k8s-components-version.sh $i)" "https://gitlab.com/api/v4/projects/6226059/repository/files/versions%2F${i}.txt?branch=master&commit_message=create%20${i}.txt"
done

rm -f ./k8s-version.txt
cp ./k8s-version-new.txt ./k8s-version.txt
