<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:changes="http://maven.apache.org/changes/1.0.0"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

    <xsl:output standalone="yes" method="text" />

    <xsl:include href="chunker.xsl" />
    <xsl:include href="rst.xsl" />

    <xsl:param name="changes.scm.uri" select="'http://scm.example.com'" />
    <xsl:param name="changes.pear.uri" select="'http://pear.example.com'" />
    <xsl:param name="changes.static.uri" select="'http://static.example.com'" />

    <xsl:param name="changes.copyright" select="'All rights reserved'" />

    <xsl:param name="changes.builddir" select="'/path/to/build/dir'" />
    <xsl:param name="changes.webdir" select="'/path/to/docroot'" />

    <xsl:param name="changes.project.name" select="'example'" />

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
        <xsl:apply-templates select="." mode="release-archive">
            <xsl:sort select="@version" order="descending" />
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="release-index">
            <xsl:sort select="@version" order="descending" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="changes:body" mode="release-archive">
        <xsl:call-template name="write.chunk">
            <xsl:with-param name="filename" select="concat($changes.builddir, $changes.webdir, '/archive.rst')" />
            <xsl:with-param name="method" select="'text'" />
            <xsl:with-param name="encoding" select="'UTF-8'" />
            <xsl:with-param name="content">
                <xsl:call-template name="document-headline">
                    <xsl:with-param name="headline" select="concat(/changes:document/changes:properties/changes:title, ' Release Archive')" />
                </xsl:call-template>

                <xsl:for-each select="changes:release">
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
                    <xsl:value-of select="$changes.webdir" />
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="@version" />
                    <xsl:text>/changelog.html</xsl:text>
                    <xsl:value-of select="$nl" />
                    <xsl:value-of select="$nl" />
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="changes:body" mode="release-index">
        <xsl:call-template name="write.chunk">
            <xsl:with-param name="filename" select="concat($changes.builddir, $changes.webdir, '/.index.xml')" />
            <xsl:with-param name="method" select="'text'" />
            <xsl:with-param name="encoding" select="'UTF-8'" />
            <xsl:with-param name="content">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;index&gt;
    &lt;site index="false" display="false"&gt;
        &lt;name&gt;Version Archive&lt;/name&gt;
        &lt;path&gt;archive.rst&lt;/path&gt;
    &lt;/site&gt;
    <xsl:for-each select="*">
    &lt;directory&gt;
        &lt;name&gt;Version <xsl:value-of select="@version" />&lt;/name&gt;
        &lt;path&gt;<xsl:value-of select="@version" />/&lt;/path&gt;
    &lt;/directory&gt;
    </xsl:for-each>
    &lt;directory&gt;
        &lt;name&gt;Version <xsl:value-of select="*[1]/@version" />&lt;/name&gt;
        &lt;path&gt;latest/&lt;/path&gt;
    &lt;/directory&gt;
&lt;/index&gt;
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="changes:release">
        <xsl:apply-templates select="." mode="changelog-list" />
        <xsl:apply-templates select="." mode="changelog-list-archive" />
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
            <xsl:value-of select="$changes.webdir" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@version" />
            <xsl:text>/changelog.html</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-list-archive">
        <xsl:if test="count(preceding-sibling::*) = 4">
            <xsl:value-of select="$nl" />
            <xsl:text>`Release archive`__</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.webdir" />
            <xsl:text>/archive.html</xsl:text>
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changelog-files">
        <xsl:apply-templates select="." mode="changes-release-latest" />
        <xsl:apply-templates select="." mode="changes-xml-release" />
        <xsl:apply-templates select="." mode="changes-rst-release" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-release-latest">
        <xsl:if test="count(preceding-sibling::*) = 0">
            <xsl:apply-templates select="." mode="changes-xml-release">
                <xsl:with-param name="directory" select="'latest'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="." mode="changes-rst-release">
                <xsl:with-param name="directory" select="'latest'" />
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-xml-release">
        <xsl:param name="directory" select="@version" />

        <xsl:call-template name="write.chunk">
            <xsl:with-param name="filename" select="concat($changes.builddir, $changes.webdir, '/', $directory, '/.index.xml')" />
            <xsl:with-param name="method" select="'text'" />
            <xsl:with-param name="encoding" select="'UTF-8'" />
            <xsl:with-param name="content">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;index&gt;
    &lt;site index="true" display="false"&gt;
        &lt;name&gt;Version <xsl:value-of select="@version" />&lt;/name&gt;
        &lt;path&gt;changelog.rst&lt;/path&gt;
    &lt;/site&gt;
&lt;/index&gt;
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release">
        <xsl:param name="directory" select="@version" />

        <xsl:call-template name="write.chunk">
            <xsl:with-param name="filename" select="concat($changes.builddir, $changes.webdir, '/', $directory, '/changelog.rst')" />
            <xsl:with-param name="method" select="'text'" />
            <xsl:with-param name="encoding" select="'UTF-8'" />
            <xsl:with-param name="content">
                <xsl:call-template name="document-headline">
                    <xsl:with-param name="headline" select="concat('Version ', @version)" />
                </xsl:call-template>
                <xsl:apply-templates select="." mode="changes-rst-release-metadata" />
                <xsl:apply-templates select="." mode="changes-rst-release-description" />
                <xsl:apply-templates select="." mode="changes-rst-release-modifications" />
                <xsl:apply-templates select="." mode="changes-rst-release-downloads" />
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release-metadata">
        <xsl:call-template name="changes-rst-metadata-author" />
        <xsl:call-template name="changes-rst-metadata-copyright" />
        <xsl:call-template name="changes-rst-release-metadata-keywords" />
        <xsl:call-template name="changes-rst-release-metadata-description" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="changes-rst-metadata-author">
        <xsl:text>:Author:       </xsl:text>
        <xsl:value-of select="/changes:document/changes:properties/changes:author" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="changes-rst-metadata-copyright">
        <xsl:text>:Copyright:    </xsl:text>
        <xsl:value-of select="$changes.copyright" />
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="changes-rst-release-metadata-description">
        <xsl:text>:Description:  </xsl:text>
        <xsl:text>This document contains the release notes for the </xsl:text>
        <xsl:value-of select="/changes:document/changes:properties/changes:title" />
        <xsl:text> release </xsl:text>
        <xsl:value-of select="@version" />
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template name="changes-rst-release-metadata-keywords">
        <xsl:text>:Keywords:     </xsl:text>
        <xsl:text>Release, Version </xsl:text>
        <xsl:value-of select="@version" />
        <xsl:if test="count(changes:action[@type = 'fix']) &gt; 0">
            <xsl:text>, Bug, Bugfix</xsl:text>
        </xsl:if>
        <xsl:if test="count(changes:action[@type != 'fix']) &gt; 0">
            <xsl:text>, Features</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release-description">
        <xsl:if test="@description">
            <xsl:value-of select="normalize-space(@description)" />
            <xsl:value-of select="$nl" />
            <xsl:value-of select="$nl" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release-modifications">
        <xsl:apply-templates select="." mode="changes-rst-release-modifications-features" />
        <xsl:apply-templates select="." mode="changes-rst-release-modifications-fixes" />
    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release-downloads">
        <xsl:if test="$changes.pear.uri or $changes.static.uri">
            <xsl:call-template name="section-headline">
                <xsl:with-param name="headline" select="'Downloads'" />
            </xsl:call-template>

            <xsl:text>You can download release </xsl:text>
            <xsl:value-of select="@version" />
        </xsl:if>

        <xsl:if test="$changes.pear.uri">
            <xsl:text> through </xsl:text>
            <xsl:value-of select="$changes.project.name" />
            <xsl:text>'s `PEAR Channel Server`__</xsl:text>
            <xsl:choose>
                <xsl:when test="$changes.static.uri">
                    <xsl:text> or you can download this release </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$changes.static.uri">
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

        <xsl:if test="$changes.static.uri">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.static.uri" />
            <xsl:text>/php/</xsl:text>
            <xsl:value-of select="@version" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$changes.project.name" />
            <xsl:text>.phar</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl" />

    </xsl:template>

    <xsl:template match="changes:release" mode="changes-rst-release-modifications-features">
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

    <xsl:template match="changes:release" mode="changes-rst-release-modifications-fixes">

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

        <xsl:variable name="tracker.uri">
            <xsl:apply-templates select="." mode="changelog-list-tracker-uri" />
        </xsl:variable>

        <xsl:text>- </xsl:text>
        <xsl:value-of select="$action" />
        <xsl:choose>
            <xsl:when test="not($tracker.uri = 'none')">
                <xsl:text> `#</xsl:text>
                <xsl:value-of select="@issue" />
                <xsl:text>`__: </xsl:text>
            </xsl:when>
            <xsl:when test="@issue">
                <xsl:text> #</xsl:text>
                <xsl:value-of select="@issue" />
                <xsl:text>: </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="normalize-space(text())" />
        <xsl:if test="@date">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$action" />
            <xsl:text> in commit `#</xsl:text>
            <xsl:value-of select="@date" />
            <xsl:text>`__.</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template match="changes:action" mode="changelog-list-link">
        <xsl:variable name="tracker.uri">
            <xsl:apply-templates select="." mode="changelog-list-tracker-uri" />
        </xsl:variable>

        <xsl:if test="not($tracker.uri = 'none')">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$tracker.uri" />
            <xsl:value-of select="$nl" />
        </xsl:if>

        <xsl:if test="@date">
            <xsl:text>__ </xsl:text>
            <xsl:value-of select="$changes.scm.uri" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@date" />
        </xsl:if>
        <xsl:value-of select="$nl" />
    </xsl:template>

    <xsl:template match="changes:action" mode="changelog-list-tracker-uri">
        <xsl:choose>
            <xsl:when test="@system and @issue">
                <xsl:choose>
                    <xsl:when test="@system = 'pivotaltracker'">
                        <xsl:text>https://www.pivotaltracker.com/story/show/</xsl:text>
                        <xsl:value-of select="@issue" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>none</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>none</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
