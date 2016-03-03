function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

# call with <fileName> <search_string> <replace_string>
function _replace() {
	sed "s/$2/$3/" "$1" > "/tmp/1.tmp"; _ERR
	cat "/tmp/1.tmp" > "$1"; _ERR
}

# pull lastest source code
function _gitPull(){
    git checkout develop; _ERR
	git pull; _ERR
}