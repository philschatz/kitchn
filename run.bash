set -e

echo "Generating XSL"
saxon -s:./recipe.xml -xsl:./to-xslt.xsl -o:./autogenerated.xsl 

echo "Running Transform"
saxon -s:./input.xhtml -xsl:./autogenerated.xsl -o:./output.xhtml 
