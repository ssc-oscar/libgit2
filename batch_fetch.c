#include<git2.h>
#include<zlib.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<openssl/sha.h>
#include<sys/types.h>
#include<sys/stat.h>

static const char hex_chars[] = "0123456789abcdef";
void convert_hex(unsigned char *md, unsigned char *mdstr)
{
    int i;
    int j = 0;
    unsigned int c;
    for (i = 0; i < 20; i++) {
        c = (md[i] >> 4) & 0x0f;
        mdstr[j++] = hex_chars[c];
        mdstr[j++] = hex_chars[md[i] & 0x0f];
    }
    mdstr[40] = '\0';
}

void recursive_mkdir(char *dir_path)
{
    char *tmp = strrchr(dir_path, '/');
    char *pdir = malloc(strlen(dir_path));
    memset(pdir, 0, sizeof(pdir));
    int i = 0;
    for(i = 0; i < strlen(dir_path) - strlen(tmp); ++i) {
        pdir[i] = dir_path[i];
    }
    pdir[i] = 0;
    struct stat st = {0};
    if(stat(pdir, &st) == -1) {
        mkdir(pdir, 0700);
    }
    mkdir(dir_path, 0700);
    if(pdir)
    {
        free(pdir);
    }
}

FILE* my_fopen(char *path, char *mode)
{
    char* tmp = strrchr(path, '/');
    char *dir = malloc(strlen(path));
    memset(dir, 0, sizeof(dir));
    int i = 0;
    for(i = 0; i < strlen(path) - strlen(tmp); ++i) {
        dir[i] = path[i];
    }
    dir[i] = 0;
    recursive_mkdir(dir);
    if(dir) {
        free(dir);
    }
    return fopen(path, mode);

}

int main(int argc, char *argv[])
{
    git_libgit2_init();

    git_repository *repo = NULL;
    git_remote *remote;
    git_fetch_options fetch_opts = GIT_FETCH_OPTIONS_INIT;

    int error = 0;
    if(argc < 5) {
        printf("please provide 4 parameters: git url, local repository path and file name, packfile name\n");\
        goto cleanup;
    }
    char *url = argv[1];
    char *path = argv[2];
    char *file_name = argv[3];
    char *name = argv[4];
    
    //part 1: initialize local repository
    if((error = git_repository_init(&repo, path, 0)) < 0) {
        fprintf(stderr, "initialize repository error: %s\n", giterr_last()->message);
        goto cleanup;
    }

    //part 2: put prettyfied commit content into the .git/objects directory.
    FILE *fp = fopen(file_name, "r");
    char *l0 = NULL;
    size_t size = 0;
    char seps[] = ";";
    //Here I assume that a sha;name;offset;length in a line
    while(getline(&l0, &size, stdin) >= 0) {
        char *sha = strtok(l0, seps);
        
        char *heads_name = strtok(NULL, seps);
        int offset = atoi(strtok(NULL, seps));
        int length = atoi(strtok(NULL, seps));
        fseek(fp, offset, SEEK_SET);

        //allocate a little more space, just in case of some unknown problems:)
        //form correct format
        char *content = malloc(length + 10);
        memset(content, 0, length + 10);
        fread(content, length, 1, fp);
        printf("%s\n", content);
        char *header = malloc(20);
        sprintf(header, "commit %d", length);
        char *store = malloc(strlen(header) + strlen(content) + 5);
        memset(store, 0, strlen(header) + strlen(content) + 5);
        strcpy(store, header);
        strcpy(store + strlen(header) + 1, content);

        //then hash
        unsigned char md[SHA_DIGEST_LENGTH];
        bzero(md, SHA_DIGEST_LENGTH);
        SHA1(store, strlen(header)+strlen(content)+1, md);
        char mdstr[40];
        bzero(mdstr, 40);
        convert_hex(md, mdstr);
        printf ("Result of SHA1 : %s\n", mdstr);
        
        //must get sourceLen as the form, as store has a null pointer after header
        uLong sourceLen = strlen(header) + strlen(content) + 1;
        uLong compressSize = compressBound(sourceLen);
        Bytef *dest = (Bytef *)malloc(compressSize);
        memset(dest, 0, compressSize);
        compress(dest, &compressSize, (Bytef *)store, sourceLen);

        //write the compressed content to the file
        char *obj_dir_path = malloc(strlen(path) + strlen("/.git/objects/") + 5);
        memset(obj_dir_path, 0, sizeof(obj_dir_path));
        strcpy(obj_dir_path, path);
        strcat(obj_dir_path, "/.git/objects/");
        char obj_dir_name[3];
        for(int i = 0; i < 2; i++) {
            obj_dir_name[i] = mdstr[i];
        }
        obj_dir_name[2] = 0;
        strcat(obj_dir_path, obj_dir_name);

        //create dir if it doesn't exist
        struct stat st = {0};
        if(stat(obj_dir_path, &st) == -1) {
            mkdir(obj_dir_path, 0700);
        }
        
        char *obj_file_path = malloc(strlen(obj_dir_path) + 50);
        memset(obj_file_path, 0, strlen(obj_dir_path) + 50);
        strcpy(obj_file_path, obj_dir_path);
        strcat(obj_file_path, "/");
        char obj_file_name[40];
        for(int i = 0; i < 38; i++) {
            obj_file_name[i] =  mdstr[i+2];
        }
        obj_file_name[38] = 0;
        strcat(obj_file_path, obj_file_name);
        FILE *out = fopen(obj_file_path, "wb");
        fwrite(dest, compressSize, 1, out);
        fclose(out);

        char *refs_heads_path = malloc(strlen(path) + strlen("/.git/refs/heads/") + strlen(heads_name) + 10);
        memset(refs_heads_path, 0, strlen(path) + strlen("/.git/refs/heads/") + strlen(heads_name) + 10);
        strcpy(refs_heads_path, path);
        strcat(refs_heads_path, "/.git/refs/heads/");
        strcat(refs_heads_path, heads_name);
        FILE *out2 = my_fopen(refs_heads_path, "w");
        fwrite(sha, strlen(sha), 1, out2);
        fwrite("\n", 1, 1, out2);
        fclose(out2);
        
        if(content) {
            free(content);
        }
        if(header) {
            free(header);
        }
        if(store){
            free(store);
        }
        if(dest) {
            free(dest);
        }
        if(obj_dir_path) {
            free(obj_dir_path);
        }
        if(obj_file_path) {
            free(obj_file_path);
        }
        if(refs_heads_path) {
            free(refs_heads_path);
        }

    }  

    //part 3: fetch
    if  ((error = git_remote_lookup(&remote, repo, "origin")) < 0) {
        if((error = git_remote_create(&remote, repo, "origin", url)) < 0) {
            fprintf(stderr, "add remote error: %s\n", giterr_last()->message);
        }
    }
    printf("%s\n", packfile_name);
    packfile_name = name;
    
    error = git_remote_fetch(remote, NULL, &fetch_opts, NULL);
    if(error < 0) {
        fprintf(stderr, "fetch error: %s\n", giterr_last()->message);
        goto cleanup;
    }    

cleanup:
    if (repo) {
        git_repository_free(repo);
    }
    if (remote) {
        git_remote_free(remote);
    }

    git_libgit2_shutdown();
    return 0;
}

/*a test case:
./batch_fetch https://github.com/pidanself/Testbranch /home/kaigao/Testbranch /home/kaigao/txt /home/kaigao/packfile
082d5e91a657b93e15395d76074316b3b70e57e7;master;0;796;
be5a7ee90f39b3fc9b7fba0042706a6a33051603;branch2;796;255;


/home/kgao/Testbranch is the folder name for initialize a local repo
/home/kgao/txt is the file name where store the commit's content
/home/kgao/packfile is packfile's name. Here I assume that the file's located folder has existed before
next the input, folleing the format: sha;head's name;offset;length
*/