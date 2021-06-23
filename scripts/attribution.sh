#!/bin/bash 

# @author Neil Hanlon <neil@rockylinux.org> 
# @date 2021-02-26 
# @desc This script takes an input filename and returns as output a
# yaml-compatible document to be appended into file metadata for attribution of
# contributors to documentation articles

function debug() {
    # @param    $1  - string to be formatted as a debug if debug is set
    if [[ $DEBUG ]]; then
        printf "[DEBUG] %s %s\n" $(date +'%Y-%m-%d %H:%M:%S') "$1"
    fi
}

function format_contributor() {
    # @param    commiter    - the contributor's detail string (from locals)
    # @return   output      - the formatted string
    output=$(echo ${commiter} | awk -F\; '{print $2}')
}

function format() {
    # @param    contributor_set       - the array to iterate on and output; it
    #                                   should be sorted by commit date, 
    #                                   ascending.
    # @stdout   formatted text        - formatted output in yaml

    # Add a yaml document header
    echo '---'
    # The author is the first one to commit
    printf "author: '%s'\n" "${contributor_set[0]}"

    # Everyone else is a contributor. As long as there is more than one
    # commiter, loop through them and append them to the line.
    printf "contributors: '"
    if [[ "${#contributor_set[@]}" -ge 1 ]]; then 
        for c in "${contributor_set[@]:1}"; do
            if [[ "$c" != "${contributor_set[-1]}" ]]; then
                printf "%s, " "$c"
            else
                printf "%s" "$c"
            fi
        done 
    fi
    printf "'\n"

    printf "%s\n" "$(awk '// {print}' $file)"

    # Add the yaml document footer
    printf "...\n"
}

function process_contributors() {
    ##
    # This function takes an indexed array of formatted git hashes, processes
    # them to make them unique, and returns a yaml-compliant output to be used
    # in documentation headers/metadata.
    #
    # @param $1 - the name of an indexed array to walk
    ##
    local -n ref=$1

    # format looks like this, so we change IFS and re-read to make each element
    # of the array a commiter; With whitespace because I hate bash
    # d20a845;Full Name;email@example.com| 5e31b956;Another Person;email2@example.com|
    _IFS=$IFS
    IFS='|'
    local -a commiters=($ref)
    IFS=$_IFS


    # Loop through every commiter; Skip if it is empty or if the formatted
    # version is already contained in the output array. (Unique it)
    local -a contributor_set # Ordered Set containing contributors for the file

    local commiter
    local -a output=()
    for commiter in "${commiters[@]}"; do
        format_contributor # returns formatted version in $output
        if [[ $commiter == '' || "${contributor_set[*]}" =~ $output ]]; then
            continue;
        else
            contributor_set=("${output}" "${contributor_set[@]}")
        fi
    done

    # Call the format function to process $contributor_set and output
    format
}


file="$1"

# Try to find the original author of this file
cmd="git log --pretty=format:%h;%an;%ae|"

# Run the git log twice. Once as --follow, once without.
# --follow returns the same output as no-follow if the file has not been renamed
# but if the file is renamed, --follow returns ONLY the commits associated with
# the linked git object in the tree, and no-follow returns the current-HEAD file
mapfile -t follow < <(${cmd} --follow ${file})
mapfile -t normal < <(${cmd} ${file})

# Check to see if the command outputs are identical, and if so, just use one of
# them to assign attribution
if [[ "${follow[@]}" == "${normal[@]}" ]]; then
    process_contributors follow
else
    # If the command outputs are not identical, then concatenate the arrays
    # together, preserving order by keeping the older (follow) commits first.
    combined=("${follow[@]}" "${normal[@]}")
    process_contributors combined[@] # Nondimensionalize the array, as expected
                                     # by the called function
fi

exit 0
