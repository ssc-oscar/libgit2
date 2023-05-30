gcloud compute instances create instance-1 \
    --project=nsf-2120429-146403 \
    --zone=us-central1-a \
    --machine-type=e2-custom-8-32768 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=913458700703-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=https-server \
    --create-disk=boot=yes,device-name=instance-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230302,mode=rw,size=1200,type=projects/nsf-2120429-146403/zones/us-central1-a/diskTypes/pd-ssd \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any


    174,148,173,179,193,204,214,224,235,242,255,253m6,264,263,274,284,282,292:1:ubuntu-template-5:gcp5:35.226.238.36:sailvm3
    167,172,176,182,205,202,215,222,225,234,245,254,265,275,273,285,283m01,271:2:ubuntu-template-4:gcp4:34.162.108.202:utk3
        166,186,183,195,192,203,216,212,236,246,256,266,262,276,286,291,281,289:3:ubuntu-template-2:gcp3:utk1
   187,184,197,196,207,217,206,213,227,237,247m,257,267,277,287,288,294,261:4:instance-template-1:gcp2:sailbrain0
    188,185,198,194,208,218,228,223,238,248,244,258m14,268,272,278,293:5:ubuntu-template-1:gcp1:sailvm1
162,189,199,209,219,229,226,239,232,233,249,252m10,259,243,269,279:6:ubuntu-template-3:gcp:34.162.9.187:utk2

for i in {296..320}; do echo $i $(ls V.$i|wc -l) $(wc -l V.$i/list*) ; done
ng:   301,296,297,317,300
isac: 314,298,316,319
gcp:  302,308,307,309,310,311,312
gcp1: 320,315,299,303,304,305,306,318,313


320:
SuperSonicHub1_fbi-most-wanted-scraper
HERA-Team_H6C_Notebooks
302:
HERA-Team_H5C_Notebooks


279: exclude BullshitDays_race-pi-maxio-1
272: exclude LoR-Master_LoR-Master-Crawler
262: exclude 43EVER_mc
268: exclude HERA-Team_H5C_Notebooks
216: moiify_AutoGreen  - not complete: 216
179: exluded mozilla-platform-ops_bean-counter
do mozilla-platform-ops_bean-counter
       
n=XXX;time ./doV.sh $n &> $n.err; n=$((n+10)); time ./doV.sh $n &> $n.err

260..10:ng   200
261..10:acf
for i in gcp gcp1 gcp2 gcp3 gcp4 gcp5; do scp -p .ssh/c.$i $i:.ssh/config ; done
for i in gcp gcp1 gcp2 gcp3 gcp4 gcp5; do scp -p doV.sh $i:; done

for i in gcp gcp1 gcp2 gcp3 gcp4 gcp5; do scp -p bin/listBatch.sh $i:bin/; done
for i in gcp gcp1 gcp2 gcp3 gcp4 gcp5; do scp -p doV.sh $i:; done

#via web shell
sudo bash
apt update
apt install -y make gcc tmux git rsync bc
exit
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJewRVAz2ncu5uCOmI0jkrmqCqX9XO95hrUVAoWnQVbM audris@utk.edu" >> $HOME/.ssh/authorized_keys

#on laptop
scp -p bin/listBatch.sh $GCP:bin
scp -p badprojects $GCP:
GCP=gcp5
scp -pr .profile lib Compress-LZF-3.41  bin  doV.sh $GCP:
scp -p .ssh/id* $GCP:.ssh/
scp -p .ssh/c.$GCP $GCP:.ssh/config


ssh $GCP
tmux

cd Compress-LZF-3.41
perl Makefile.PL PREFIX=/home/audris
make
make test
make install
cd ..

git clone --mirror gh:fdac22/news
gitListSimp.sh news.git | classify news.git|perl -I $HOME/lib/x86_64-linux-gnu/perl $HOME/bin/grabGitI.perl news.git
ssh da7
#the above looks good? start
n=299;time ./doV.sh $n &> $n.err



#################################
gcloud compute instances create instance-2 \
    --project=nsf-2120429-146403 \
    --zone=us-west1-b \
    --machine-type=e2-custom-8-32768 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=913458700703-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=https-server \
   --create-disk=auto-delete=yes,boot=yes,device-name=instance-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230302,mode=rw,size=1200,type=projects/nsf-2120429-146403/zones/us-west1-b/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
   --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any
gcloud compute instances create instance-2 \
    --project=nsf-2120429-146403 \
    --zone=us-west1-b \
    --machine-type=e2-standard-16 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=913458700703-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230302,mode=rw,size=1200,type=projects/nsf-2120429-146403/zones/us-west1-b/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any
