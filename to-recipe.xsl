<!--

Helpful references:

XSLT3.0: https://www.w3.org/TR/xslt-30/
XPath functions: https://www.w3.org/TR/xpath-functions-30/

-->

<xsl:transform
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="urn:recipe-config-xml"
    xmlns:r="urn:replacer-xml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="g"
    expand-text="yes"
    version="3.0">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
    <xsl:comment>This file is autogenerated. DO NOT EDIT.</xsl:comment>
    <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="g:root">
    <r:root>
        <r:replace selector="h:body">
            <r:declare>
                <r:bucket name="solutionBucket"/>
                <r:counter name="chapterCounter" selector="*[@data-type='chapter']"/>
            </r:declare>

            <r:this>
                <r:children/>

                <xsl:apply-templates select="g:book-page-solutions | g:book-page | g:index"/>
            </r:this>

            <!--Chapter-->
            <r:replace selector="*[@data-type='chapter']">
                <r:declare>
                    <r:link-text>Chapter <r:dump-counter name="chapterCounter"/></r:link-text>
                    <r:counter name="sectionCounter" selector="*[@data-type='page']"/>
                    <r:counter name="exerciseCounter" selector="*[@data-type='exercise']"/>
                    <r:counter name="figureCounter" selector="h:figure"/>
                    <r:counter name="tableCounter" selector="h:table"/>

                    <xsl:for-each select="g:chapter-page">
                        <r:bucket name="iamapagebucket-{@class}"/>
                    </xsl:for-each>
                </r:declare>

                <r:this>
                    <h2>Chapter <r:dump-counter name="chapterCounter"/></h2>
                    <r:children/>
                    <xsl:apply-templates select="g:chapter-page"/>
                </r:this>

                <xsl:for-each select="g:chapter-page">
                    <r:replace move-to="iamapagebucket-{@class}" selector="*[@class='{@class}']">
                        <xsl:comment>TODO: BUG: Unwrap the section and remove the title</xsl:comment>
                        <r:this h:data-todo="UNWRAPME">
                            <r:children selector="node()[not(self::*[@data-type='title'])]"/>
                        </r:this>
                    </r:replace>
                </xsl:for-each>

                <!--Exercise that has a solution-->
                <r:replace selector="*[@data-type='exercise'][*[@data-type='solution']]">
                    <r:declare>
                        <r:link-text>
                            <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="exerciseCounter"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <r:link to="child" selector="*[@data-type='solution']"><r:dump-counter name="exerciseCounter"/></r:link>
                        <r:children/>
                    </r:this>

                    <!--Solution-->
                    <r:replace move-to="solutionBucket" selector="*[@data-type='solution']">
                        <r:this>
                            <r:link to="parent"/>
                            <r:children/>
                        </r:this>
                    </r:replace>
                </r:replace>

                <!--Exercise with no solution-->
                <r:replace selector="*[@data-type='exercise'][not(*[@data-type='solution'])]">
                    <r:declare>
                        <r:link-text>
                            <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="exerciseCounter"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <strong>
                            <r:dump-counter name="exerciseCounter"/>
                        </strong>
                        <r:children/>
                    </r:this>
                </r:replace>

                <!--Table-->
                <r:replace selector="h:table">
                    <xsl:apply-templates select="g:table-caption[@in='ANY_PART' or @in='CHAPTER_PART']"/>
                </r:replace>

                <!--Figure-->
                <r:replace selector="h:figure">
                    <xsl:apply-templates select="g:figure-caption[@in='ANY_PART' or @in='CHAPTER_PART']"/>
                </r:replace>

                <!--Note-->
                <xsl:apply-templates select="g:note"/>

                <!--Section-->
                <r:replace selector="*[@data-type='page']">
                    <r:declare>
                        <r:link-text>
                            <!--TODO: Maybe copy-content should somehow squirrel away the original content instead of the expanded content-->
                            <!-- <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="sectionCounter"/>:  -->
                            <r:copy-content selector="./*[@data-type='document-title']/node()"/>
                        </r:link-text>
                    </r:declare>
                    
                    <r:this>
                        <r:children/>
                    </r:this>

                    <!-- Add the section number to the title -->
                    <r:replace selector="*[@data-type='document-title']">
                        <r:this>
                            <r:dump-counter name="chapterCounter"/>.<r:dump-counter name="sectionCounter"/>: <r:children/>
                        </r:this>
                    </r:replace>
                </r:replace>

            </r:replace>

        </r:replace>

    </r:root>
</xsl:template>

<xsl:template match="g:book-page-solutions">
    <div data-type="composite-chapter" data-uuid-key=".{@class}" class="os-eob os-{@class}-container">
        <h1 data-type="document-title">
            <span class="os-text">{@name}</span>
        </h1>
        <r:dump-bucket name="solutionBucket" group-by="*[@data-type='chapter']" group-by-title="./*[@data-type='document-title']"/>
    </div>
</xsl:template>

<xsl:template match="g:chapter-page">
    <div data-type2-because-bug="page" data-uuid-key=".{@class}">
        <h2>{@name}</h2>
        <xsl:choose>
            <xsl:when test="@cluster='YES'">
                <r:dump-bucket name="iamapagebucket-{@class}" group-by="*[@data-type='page']" group-by-title="./*[@data-type='document-title']"/>
            </xsl:when>
            <xsl:otherwise>
                <r:dump-bucket name="iamapagebucket-{@class}"/>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="g:table-caption[@placement='TOP']">
    <div class="os-table">
        <div class="os-caption-container">
            <xsl:apply-templates select="node()"/>
            <r:children selector="h:caption/node()"/>
        </div>
        <r:this h:class="top-titled">
            <r:children selector="node()[not(self::h:caption)]"/>
        </r:this>
    </div>
    
</xsl:template>


<xsl:template match="g:figure-caption[@placement='BOTTOM']">
    <div class="os-figure">
        <r:this>
            <r:children selector="node()[not(self::h:figcaption)]"/>
        </r:this>
        <div class="os-caption-container">
            <r:children selector="h:figcaption"/>
        </div>
    </div>
    
    <!--Caption-->
    <r:replace selector="h:figcaption">
        <r:this>
            <strong>
                <xsl:apply-templates select="node()"/>
            </strong>
            <r:children/>
        </r:this>
    </r:replace>
</xsl:template>

<xsl:template match="g:figure-caption[@placement='TOP']">
    <div class="os-figure">
        <div class="os-caption-container">
            <r:children selector="h:figcaption"/>
        </div>
        <r:this>
            <r:children selector="node()[not(self::h:figcaption)]"/>
        </r:this>
    </div>
    
    <!--Caption-->
    <r:replace selector="h:figcaption">
        <r:this>
            <strong>
                <xsl:apply-templates select="node()"/>
            </strong>
            <r:children/>
        </r:this>
    </r:replace>
</xsl:template>

<xsl:template match="g:note">
    <r:replace selector="*[@data-type='note']" class="{@class}">
        <r:this h:class="os-note {@class}"><!--HACK: Should have a way to append the class-->
            <h:h6 data-type="title" class="os-note-title">{@name}</h:h6>
            <h:div class="os-note-body">
                <r:children selector="*[not(@data-type='title')]"/>
            </h:div>
        </r:this>
    </r:replace>
</xsl:template>

<!-- Identity Transform -->
<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

</xsl:transform>