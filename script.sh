sudo apt-get update
sudo apt-get install -y make
sudo apt-get install -y gcc
git clone https://github.com/eembc/coremark.git
cd coremark
cpu_size=$(grep -c processor /proc/cpuinfo)
make clean
make XCFLAGS="-DMULTITHREAD=${cpu_size} -DUSE_FORK"
cp run2.log /home/azureuser/run2.log
model_name=$(grep "model name" /proc/cpuinfo | head -1 | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
# Extract the "Iterations/Sec" line from the log file
iterations_sec=$(grep "Iterations/Sec" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
coremark_size=$(grep "CoreMark Size" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
total_ticks=$(grep "Total ticks" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
total_time=$(grep "Total time (secs)" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
compiler_version=$(grep "Compiler version" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
compiler_flags=$(grep "Compiler flags" /home/azureuser/run2.log | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
# Get the current date and hostname
date=$(date +%Y%m%d_%H%M%S)
hostname=$(hostname)
# Create a JSON file
json_file="/home/azureuser/${hostname}_${date}.json"
echo -e "{\n\t\"hostname\": \"$hostname\",\n\t\"date\": \"$date\",\n\t\"model_name\": \"$model_name\",\n\t\"iterations_sec\": \"$iterations_sec\",\n\t\"coremark_size\": \"$coremark_size\",\n\t\"total_ticks\": \"$total_ticks\",\n\t\"total_time\": \"$total_time\",\n\t\"compiler_version\": \"$compiler_version\",\n\t\"compiler_flags\": \"$compiler_flags\"\n}" > $json_file
# Define the base SAS URL without the blob name
base_sas_url="https://YOUR_BLOBL_HERE.blob.core.windows.net/results"
# Define the blob name based on the hostname and date
blob_name="${hostname}_${date}.json"
# Define the full SAS URL
sas_url="${base_sas_url}/${blob_name}?sp=racwl&st=2023-12-06T21:00:58Z&se=2023-12-31T05:00:58Z&spr=https&sv=2022-11-02&sr=c&sig=SAS_KEY_HERE"
# Upload the JSON file to Azure Blob Storage
curl -X PUT -T $json_file -H "x-ms-blob-type: BlockBlob" $sas_url