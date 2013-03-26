<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output encoding="UTF-8"
                indent="yes"
                method="xml" />

    <!--
        Variables filled by ANT call
    -->
    <xsl:param name="abc.project.default-target" />
    <xsl:param name="ant.project.build-file" />
    <xsl:param name="ant.project.name" />
    <xsl:param name="ant.basedir" />
    <xsl:param name="user.dir" />

    <xsl:param name="abc.extensions.directory" />
    <xsl:param name="project.extensions.directory" />

    <!--
        Basic Document Transformations
    -->
    <xsl:template match="/">
        <project name="{$ant.project.name}#generated"
                 basedir="{$ant.basedir}"
                 default="{$abc.project.default-target}">

            <import file="{$ant.project.build-file}" />

            <property name="abc:project.name" value="{$ant.project.name}" />

            <xsl:apply-templates select="/abc/project" />

            <target name="configure">
                <ant antfile="{$ant.project.build-file}"
                     dir="{$user.dir}"
                     target="configure"
                     useNativeBasedir="true" />
            </target>
        </project>
    </xsl:template>

    <xsl:template match="/abc/project">
        <xsl:variable name="profile.enabled">
            <xsl:choose>
                <xsl:when test="not(starts-with(@name, 'ABC:Core:'))">
                    <xsl:call-template name="profile.enabled">
                        <xsl:with-param name="profile.name">
                            <xsl:call-template name="profile.from.project.name">
                                <xsl:with-param name="project.name"
                                                select="@name" />
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>true</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$profile.enabled = 'true'">
            <xsl:element name="import">
                <xsl:attribute name="file">
                    <xsl:call-template name="file.from.project.name">
                        <xsl:with-param name="project.name" select="@name" />
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--
        Utillity Functions
    -->
    <xsl:template name="profile.from.project.name">
        <xsl:param name="project.name" />

        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

        <xsl:value-of select="concat(
                'profile.',
                translate(
                    translate(
                        $project.name,
                        $uppercase,
                        $lowercase
                    ),
                    ':',
                    '.'
                )
            )" />
    </xsl:template>

    <xsl:template name="file.from.project.name">
        <xsl:param name="project.name" />

        <xsl:variable name="extensions.directory">
            <xsl:choose>
                <xsl:when test="starts-with($project.name, 'ABC:')">
                    <xsl:value-of select="$abc.extensions.directory" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$project.extensions.directory" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="concat(
                $extensions.directory,
                '/',
                translate($project.name, ':', '/'),
                '/Extension.xml'
            )" />
    </xsl:template>

    <xsl:template name="profile.enabled">
        <xsl:param name="profile.name" />

        <xsl:choose>
            <xsl:when test="/abc/properties/property[@name = $profile.name]">
                <xsl:choose>
                    <xsl:when test="/abc/properties/property[@name = $profile.name][@value = 'enabled']">
                        <xsl:text>true</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>false</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$profile.name != 'profile'">
                <xsl:call-template name="profile.enabled">
                    <xsl:with-param name="profile.name">
                        <xsl:call-template name="profile.get.parent">
                            <xsl:with-param name="profile.name"
                                            select="$profile.name" />
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="profile.get.parent">
        <xsl:param name="profile.name" />

        <xsl:if test="contains($profile.name, '.')">
            <xsl:value-of select="substring-before($profile.name, '.')" />
            <xsl:if test="contains(substring-after($profile.name, '.'), '.')">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:call-template name="profile.get.parent">
                <xsl:with-param name="profile.name"
                                select="substring-after($profile.name, '.')" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
