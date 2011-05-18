<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:changes="http://maven.apache.org/changes/1.0.0"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

    <xsl:output standalone="yes" method="text" />

    <xsl:include href="rst.xsl" />

    <xsl:param name="changes.issues.uri" select="'https://www.pivotaltracker.com/story/show'" />
    <xsl:param name="changes.scm.uri" select="'https://github.com/phpmd/phpmd/commit'" />
    <xsl:param name="changes.pear.uri" select="'http://pear.phpmd.org'" />
    <xsl:param name="changes.phar.uri" select="'http://static.phpmd.org'" />

    <xsl:param name="changes.builddir" select="'/tmp/releases'" />
    <xsl:param name="changes.author" select="'Manuel Pichler'" />
    <xsl:param name="changes.copyright" select="'All rights reserved'" />

    <xsl:param name="changes.release.path" select="'/downloads/releases'" />

    <xsl:param name="project.name" select="'phpmd'" />

    <xsl:variable name="nl">
        <xsl:text>
</xsl:text>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <xsl:template match="changes:properties">
        <!-- -->
    </xsl:template>

    <xsl:template match="changes:document">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <xsl:template match="changes:body">
        <xsl:apply-templates select="*">
            <xsl:sort select="@version" order="descending" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="changes:release">
        <xsl:apply-templates select="." mode="changelog-list" />
        <xsl:apply-templates select="." mode="changelog-files" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-list">
        <xsl:if test="count(preceding-sibling::*) &lt; 5">
            <xsl:text>- `Version </xsl:text>
            <xsl:value-of select="@version" />
            <xsl:text>`__</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
            <xsl:text>  Release date </xsl:text>
            <xsl:value-of select="@date" />
            <xsl:if test="count(changes:action[@type = 'fix']) = 1">
                <xsl:text>; 1 bug fixed</xsl:text>
            </xsl:if>
            <xsl:if test="count(changes:action[@type = 'fix']) &gt; 1">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="count(changes:action[@type = 'fix'])" />
                <xsl:text> bugs fixed</xsl:text>
            </xsl:if>
            <xsl:if test="count(changes:action[@type != 'fix']) = 1">
                <xsl:text>; 1 feature implemented</xsl:text>
            </xsl:if>
            <xsl:if test="count(changes:action[@type != 'fix']) &gt; 1">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="count(changes:action[@type != 'fix'])" />
                <xsl:text> features implemented</xsl:text>
            </xsl:if>
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.release.path" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@version" />
            <xsl:text>/changelog.html</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-files">
        <exsl:document href="{$changes.builddir}/{@version}/.index.xml"
                       method="xml"
                       version="1.0"
                       encoding="UTF-8">
            <index>
                <site index="true" display="false">
                    <name>Release {@version}</name>
                    <path>changelog.rst</path>
                </site>
            </index>
        </exsl:document>
        <exsl:document href="{$changes.builddir}/{@version}/changelog.rst" method="text">
            <xsl:call-template name="document-headline">
                <xsl:with-param name="headline" select="concat('Release ', @version)" />
            </xsl:call-template>

            <xsl:apply-templates select="." mode="changelog-header" />
            <xsl:apply-templates select="." mode="changelog-description" />
            <xsl:apply-templates select="." mode="changelog-changes" />
            <xsl:apply-templates select="." mode="changelog-downloads" />
        </exsl:document>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-header">
        <xsl:text>:Author:     </xsl:text>
        <xsl:value-of select="$changes.author" />
        <xsl:value-of select="$nl" />

        <xsl:text>:Copyright:  </xsl:text>
        <xsl:value-of select="$changes.copyright" />
        <xsl:value-of select="$nl" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-description">
        <xsl:if test="@description">
            <xsl:value-of select="normalize-space(@description)" />
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-changes">
        <xsl:apply-templates select="." mode="changelog-features" />
        <xsl:apply-templates select="." mode="changelog-fixes" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-downloads">
        <xsl:if test="$changes.pear.uri or $changes.phar.uri">
            <xsl:call-template name="section-headline">
                <xsl:with-param name="headline" select="'Downloads'" />
            </xsl:call-template>

            <xsl:text>You can download release </xsl:text>
            <xsl:value-of select="@version" />
        </xsl:if>

        <xsl:if test="$changes.pear.uri">
            <xsl:text> through </xsl:text>
            <xsl:value-of select="$project.name" />
            <xsl:text>'s `PEAR Channel Server`__</xsl:text>
            <xsl:choose>
                <xsl:when test="$changes.phar.uri">
                    <xsl:text> or you can download this release </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$changes.phar.uri">
            <xsl:text>as a `Phar archive`__ here</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$nl" />
        <xsl:value-of select="$nl" />

        <xsl:if test="$changes.pear.uri">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.pear.uri" />
        </xsl:if>
        <xsl:value-of select="$nl" />

        <xsl:if test="$changes.phar.uri">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.phar.uri" />
            <xsl:text>/php/</xsl:text>
            <xsl:value-of select="@version" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$project.name" />
            <xsl:text>.phar</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl" />

    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-features">
        <xsl:if test="changes:action[@type != 'fix']">
            <xsl:call-template name="section-headline">
                <xsl:with-param name="headline" select="'Features'" />
            </xsl:call-template>

            <xsl:apply-templates select="changes:action[@type != 'fix']" mode="changelog-list-item">
                <xsl:with-param name="action" select="'Implemented'" />
            </xsl:apply-templates>
            <xsl:value-of select="$nl" />

            <xsl:apply-templates select="changes:action[@type != 'fix']" mode="changelog-list-link" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-fixes">

        <xsl:if test="changes:action[@type = 'fix']">
            <xsl:call-template name="section-headline">
                <xsl:with-param name="headline" select="'Bugfixes'" />
            </xsl:call-template>

            <xsl:apply-templates select="changes:action[@type = 'fix']" mode="changelog-list-item">
                <xsl:with-param name="action" select="'Fixed'" />
            </xsl:apply-templates>
            <xsl:value-of select="$nl" />

            <xsl:apply-templates select="changes:action[@type = 'fix']" mode="changelog-list-link" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:action" mode="changelog-list-item">
        <xsl:param name="action" select="''" />

        <xsl:if test="@issue">
            <xsl:text>- </xsl:text>
            <xsl:value-of select="$action" />
            <xsl:text> `#</xsl:text>
            <xsl:value-of select="@issue" />
            <xsl:text>`__: </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(text())" />
        <xsl:if test="@date">
            <xsl:value-of select="$action" />
            <xsl:text> in commit `#</xsl:text>
            <xsl:value-of select="@date" />
            <xsl:text>`__.</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template match="changes:action" mode="changelog-list-link">
        <xsl:if test="@issue">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.issues.uri" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@issue" />
        </xsl:if>
        <xsl:value-of select="$nl" />
        <xsl:if test="@date">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.scm.uri" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@date" />
        </xsl:if>
        <xsl:value-of select="$nl" />
    </xsl:template>

</xsl:stylesheet>