# Generate png images to display in README.md

if [[ "$1" == "-a" ]]; then
    alpha_flag=true
else
    alpha_flag=false
fi

mkdir -p png/  # create the png/ directory if it does not already exist

# Convert with white background by default
if $alpha_flag; then
    for pdfile in *.pdf ; do
        echo "Converting ${pdfile}"
        convert -density 500 "${pdfile}" "png/${pdfile%.*}.png"
    done
else
    for pdfile in *.pdf ; do
        echo "Converting ${pdfile}"
        convert -density 500 -background white -alpha remove -alpha off "${pdfile}" "png/${pdfile%.*}.png"
    done
fi

# create an array of PNG filenames
png_files=(png/*-*.png)

# check which pages are missing and add them to a list
missing_pages=()
for ((i=0; i<${#png_files[@]}; i++)); do
    page_number=$((i+1))
    if ! grep -q "^\!\[Page $page_number\]" README.md; then
        missing_pages+=($page_number)
    fi
done

# generate Markdown text for the missing pages and append it to the README.md file
if [ ${#missing_pages[@]} -gt 0 ]; then
    echo "The following pages are missing:"
    for page_number in ${missing_pages[@]}; do
        echo "- Page $page_number"
    done
    for ((i=0; i<${#png_files[@]}; i++)); do
        page_number=$((i+1))
        if [[ " ${missing_pages[@]} " =~ " $page_number " ]]; then
            echo "Adding Page $page_number"
            echo "![Page $page_number](${png_files[$i]})" >> README.md
        fi
    done
fi
