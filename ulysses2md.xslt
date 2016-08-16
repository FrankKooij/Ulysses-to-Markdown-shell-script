<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"
    indent="no" standalone="yes"/>

<!--
    XSLT Style sheet for transforming Ulysses Content.xml to Multimarkdown
    (c) MIT 2016, @rovest
    Not for commercial use, but free for personal use, on your own risk.
    Version 1.1, 2015-01-13 at 21:44 IST
    Added "search-and-replace" template, for unicode-LF (&#x2028;) -> "2 x space + LF"
    Feel free to use and improve.
-->

<xsl:template match="/">
    <xsl:apply-templates select="sheet/string/p"/>
    <xsl:apply-templates select="//element[@kind='footnote']/attribute/string"/>
    <xsl:apply-templates select="sheet/attachment"/>
</xsl:template>

<xsl:template match="p">
    <xsl:apply-templates />
    <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="p[tags/tag[@kind='comment']]">
    <xsl:text>&lt;!--</xsl:text>
        <xsl:apply-templates />
    <xsl:text>--&gt;&#10;</xsl:text>
</xsl:template>

<xsl:template match="p[tags/tag[@kind='nativeblock']]">
    <xsl:text></xsl:text><xsl:value-of select="text()"/>
    <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="p[tags/tag[@kind='divider']]">
    <xsl:text>&#10;* * *&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="p[tags/tag[@kind='codeblock']]">
    <xsl:text>&#9;</xsl:text><xsl:value-of select="text()"/>
    <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="element[@startTag]">
    <xsl:value-of select="@startTag"/><xsl:apply-templates /><xsl:value-of select="@startTag"/>
</xsl:template>

<xsl:template match="element">
    <xsl:value-of select="@startTag"/><xsl:apply-templates /><xsl:value-of select="@startTag"/>
</xsl:template>

<xsl:template match="element[@kind='inlineNative']">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="element[@kind='inlineComment' or @kind='delete']">
    <xsl:text>&lt;!--</xsl:text>
    <xsl:value-of select="@startTag"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="@startTag"/>
    <xsl:text>--&gt;</xsl:text>
</xsl:template>

<xsl:template match="element[@kind='mark']">
    <xsl:text>&lt;mark&gt;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&lt;/mark&gt;</xsl:text>
</xsl:template>

<!-- Inline Footnotes (NOT supported by many markdown editors/parsers) -->
<!--
<xsl:template match="element[@kind='footnote']">
     <xsl:text>[^</xsl:text>
     <xsl:apply-templates select="attribute/string/p"/>
     <xsl:text>]</xsl:text>
</xsl:template>
-->

<xsl:template match="element[@kind='footnote']">
<!-- Inline footnote reference number -->
    <xsl:text>[^</xsl:text>
    <xsl:value-of select="count(preceding::element[@kind='footnote']) + 1"/>
    <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="element[@kind='footnote']/attribute/string">
<!-- Footnote itself, written at bottom of Markdown file (called in the first xsl:template) -->
    <xsl:text>[^</xsl:text>
    <xsl:value-of select="count(preceding::element[@kind='footnote']) + 1"/>
    <xsl:text>]: </xsl:text>
    <xsl:apply-templates select="p"/>
    <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="element[@kind='annotation']">
    <xsl:value-of select="text()"/>
    <xsl:text>&lt;!--</xsl:text>
    <xsl:apply-templates select="attribute/string/p"/>
    <xsl:text>--&gt;</xsl:text>
</xsl:template>

<xsl:template match="element[@kind='link']">
    <xsl:text>[</xsl:text><xsl:value-of select="text()"/><xsl:text>]</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="attribute[@identifier='URL']"/>
    <xsl:text> "</xsl:text>
    <xsl:value-of select="attribute[@identifier='title']"/>
    <xsl:text>")</xsl:text>
</xsl:template>

<xsl:template match="element[@kind='image']">
    <xsl:text>![</xsl:text>
    <xsl:value-of select="attribute[@identifier='description']"/>
    <xsl:text>]</xsl:text>
    <xsl:choose>
        <xsl:when test="attribute[@identifier='URL'] != ''">
            <xsl:text>(</xsl:text><xsl:value-of select="attribute[@identifier='URL']"/>
        </xsl:when>
        <xsl:otherwise>
            <!-- When embedded image, only partial image filename (UUID only) is saved,
                 also with no filetype.
                 This makes it extremely difficult to reference the image file directly in XSLT.
                 Postprocesseing Content.md with Phyton to extract complete image-filenames
                 is neccessary :( -->
            <xsl:text>(Media/</xsl:text>
            <xsl:value-of select="attribute[@identifier='image']"/>
            <!--<xsl:text>.jpeg or .tif or .gif or .png or .???</xsl:text>-->
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> "</xsl:text>
    <xsl:value-of select="attribute[@identifier='title']"/>
    <xsl:text>")</xsl:text>
</xsl:template>

<xsl:template match="*">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="text()">
    <!-- Replace Ulysses' unicode new line char with markdown equivalent: "2 x space + lf" -->
    <xsl:call-template name="search-and-replace">
        <xsl:with-param name="input" select="."/>
        <xsl:with-param name="search-string"><xsl:text>&#x2028;</xsl:text></xsl:with-param>
        <xsl:with-param name="replace-string"><xsl:text>  &#10;</xsl:text></xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="escape">
    <xsl:value-of select="."/>
</xsl:template>

<!--
<xsl:template match="@startTag">
</xsl:template>

<xsl:template match="@kind">
</xsl:template>
-->

<xsl:template match="attachment">
<!--Ulysses attachmets included as plain text in HTLM comments tags-->
        <xsl:text>&#10;&lt;!--Attachment: </xsl:text>
        <xsl:choose>
            <xsl:when test="@type='file'">
                <xsl:text>![Image](Media/</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text> "")</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@type"/>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>--&gt;&#10;</xsl:text>
</xsl:template>

<xsl:template name="search-and-replace">
    <xsl:param name="input"/>
    <xsl:param name="search-string"/>
    <xsl:param name="replace-string"/>
    <xsl:choose>
        <!-- See if the input contains the search string -->
        <xsl:when test="$search-string and contains($input,$search-string)">
            <!-- If so, then concatenate the substring before the search
                 string to the replacement string and to the result of
                 recursively applying this template to the remaining substring.
            -->
            <xsl:value-of select="substring-before($input,$search-string)"/>
            <xsl:value-of select="$replace-string"/>
            <xsl:call-template name="search-and-replace">
                <xsl:with-param name="input" select="substring-after($input,$search-string)"/>
                <xsl:with-param name="search-string" select="$search-string"/>
                <xsl:with-param name="replace-string" select="$replace-string"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <!-- There are no more occurrences of the search string so
                 just return the current input string -->
            <xsl:value-of select="$input"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>