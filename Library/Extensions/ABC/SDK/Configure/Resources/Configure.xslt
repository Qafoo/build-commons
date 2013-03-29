<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output encoding="UTF-8"
                indent="yes"
                method="xml" />

    <!--
        Variables filled by ANT call
    -->
    <xsl:param name="project.default-target" />
    <xsl:param name="project.build.file" />
    <xsl:param name="project.name" />
    <xsl:param name="project.directory" />
    <xsl:param name="project.build.directory" />
    <xsl:param name="abc.generation.target" />

    <xsl:param name="abc.extensions.directory" />
    <xsl:param name="project.extensions.directory" />

    <xsl:param name="abc.mode" />

    <!--
        Basic Document Transformations
    -->
    <xsl:template match="/">
        <project name="{$project.name}#Dependency-Generation"
                 basedir="{$project.directory}"
                 default="{$project.default-target}">

            <xsl:apply-templates select="/abc/project" />
            <xsl:apply-templates select="/abc/project/extension-point" />

            <xsl:element name="target">
                <xsl:attribute name="name">
                    <xsl:value-of select="$project.name" />
                    <xsl:text>#Dependency-Generation.Initialize</xsl:text>
                </xsl:attribute>
                <!--
                    Let the generated ant file generate the needed project header first.
                    The header does include an augmented project name, the project base dir, as well as
                    the default target to run
                -->
                <!-- concat is used, because we do not need the ending tag here, which would be
                     generated automatically, if echo xml was used -->
                <concat destfile="{$abc.generation.target}">
                    <string>
                        <xsl:value-of select="'&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;'" />
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:value-of select="'&lt;project name=&quot;'" />
                        <xsl:value-of select="$project.name" />
                        <xsl:value-of select="'#generated&quot; '" />
                        <xsl:value-of select="'basedir=&quot;'" />
                        <xsl:value-of select="$project.directory" />
                        <xsl:value-of select="'&quot; '" />
                        <xsl:value-of select="'default=&quot;'" />
                        <xsl:value-of select="$project.default-target" />
                        <xsl:value-of select="'&quot;'" />
                        <xsl:value-of select="'&gt;'" />
                        <xsl:text>&#xa;</xsl:text>
                    </string>
                </concat>

                <!-- Base properties and includes, which are always needed, regardless of
                     the enabled profiles -->
                <xsl:if test="$abc.mode = 'runtime'">
                    <echoxml file="{$abc.generation.target}" append="true">
                        <property name="abc.runtime.mode" value="true" />
                    </echoxml>
                </xsl:if>

                <!--
                    Exposed default properties based on the original build file
                    !! Can not be overwritten by the user. as they depend on the configure process !!
                -->
                <echoxml file="{$abc.generation.target}" append="true">
                    <property name="project.directory" value="{$project.directory}" />
                </echoxml>
                <echoxml file="{$abc.generation.target}" append="true">
                    <property name="project.build.directory" value="{$project.build.directory}" />
                </echoxml>

                    <!-- Import the original build file first, to allow it overwriting abc related properties -->
                <echoxml file="{$abc.generation.target}" append="true">
                    <import file="{$project.build.file}" />
                </echoxml>

                    <!--
                        Exposed default properties based on the original build file
                        !! May be overwritten by user configuration !!
                    -->
                <echoxml file="{$abc.generation.target}" append="true">
                    <property name="project.name" value="{$project.name}" />
                </echoxml>

                <!-- Load all SDK Extensions
                     They are "special" in a way, that they don't need to have a target.
                     Therefore they would not be loaded otherwise -->
                <echoxml file="{$abc.generation.target}" append="true">
                    <import>
                        <fileset dir="{$abc.extensions.directory}/ABC/SDK">
                            <include name="**/Common.xml"/>
                            <include name="**/Extension-Points.xml"/>
                            <xsl:choose>
                                <xsl:when test="$abc.mode = 'runtime'">
                                    <include name="**/Extension.xml"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <include name="**/Configuration.xml"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fileset>
                    </import>
                </echoxml>
            </xsl:element>

            <xsl:call-template name="generate.bootstrap.target">
                <xsl:with-param name="dependencies">
                    <xsl:call-template name="generate.bootstrap.dependencies" />
                </xsl:with-param>
            </xsl:call-template>
            
        </project>
    </xsl:template>

    <xsl:template name="generate.bootstrap.dependencies">
        <xsl:value-of select="concat($project.name, '#Dependency-Generation.Initialize, ')" />
        <xsl:choose>
            <xsl:when test="$abc.mode != 'runtime'">
                <xsl:value-of select="'configure'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'validate, initialize, compile, link, test, package, integration-test, verify, deploy'" />
                <xsl:value-of select="', '" />
                <xsl:value-of select="'clean'" />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="/abc/project[target[@depends = concat('-', ../@name)]]">
            <xsl:variable name="project.namespace">
                <xsl:call-template name="string.get.parent">
                    <xsl:with-param name="input" select="@name" />
                    <xsl:with-param name="delimiter" select="':'" />
                </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="profile.enabled">
                <xsl:call-template name="profile.enabled">
                    <xsl:with-param name="profile.name">
                        <xsl:call-template name="profile.from.project.namespace">
                            <xsl:with-param name="project.namespace"
                                            select="$project.namespace" />
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="$profile.enabled = 'true'">
                <xsl:value-of select="', '" />
                <xsl:value-of select="target[@depends = concat('-', ../@name)]/@name" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="generate.bootstrap.target">
        <xsl:param name="dependencies" />
        <target name="{$project.name}#Bootstrap" depends="{$dependencies}">
            <!--
                Overwrite configure target, to reconfigure the build system automatically
            -->
            <xsl:choose>
                <xsl:when test="$abc.mode = 'runtime'">
                    <echoxml file="{$abc.generation.target}" append="true">
                        <target name="configure">
                            <java classname="org.apache.tools.ant.Main"
                                  classpath="${{java.class.path}}"
                                  fork="true"
                                  taskname="configure"
                                  dir="{$project.build.directory}">
                                <arg value="-emacs" />
                                <arg value="-buildfile" />
                                <arg value="{$project.build.file}" />
                                <arg value="configure" />
                            </java>
                        </target>
                    </echoxml>
                </xsl:when>
                <xsl:otherwise>
                    <echoxml file="{$abc.generation.target}" append="true">
                        <target name="configure"
                                depends="-configure:before~hook,
                                     -configure:main~hook,
                                     -configure:after~hook" />
                    </echoxml>
                </xsl:otherwise>
            </xsl:choose>
            <concat destfile="{$abc.generation.target}"
                    overwrite="true"
                    append="true">
                <string>
                    <xsl:value-of select="'&lt;/project&gt;'" />
                </string>
            </concat>
        </target>
    </xsl:template>

    <xsl:template match="/abc/project">
        <xsl:variable name="project.name" select="@name" />

        <xsl:variable name="project.namespace">
           <xsl:call-template name="string.get.parent">
                <xsl:with-param name="input" select="$project.name" />
                <xsl:with-param name="delimiter" select="':'" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="profile.enabled">
            <xsl:choose>
                <xsl:when test="/abc/profile-defaults/profile[text() = $project.namespace and @default='disabled']">
                    <xsl:text>false</xsl:text>
                </xsl:when>
                <xsl:when test="/abc/profile-defaults/profile[text() = $project.namespace and @default='enabled']">
                    <xsl:text>true</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="profile.enabled">
                        <xsl:with-param name="profile.name">
                            <xsl:call-template name="profile.from.project.namespace">
                                <xsl:with-param name="project.namespace"
                                                select="$project.namespace" />
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="project.entrypoint"
                      select="concat('-', @name)" />

        <xsl:apply-templates select="target">
            <xsl:with-param name="project.entrypoint" select="$project.entrypoint" />
            <xsl:with-param name="profile.enabled" select="$profile.enabled" />
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="/abc/project/target">
        <xsl:param name="profile.enabled" />
        <xsl:param name="project.entrypoint" />

        <xsl:element name="target">
            <xsl:attribute name="name">
                <xsl:value-of select="@name" />
            </xsl:attribute>
            <xsl:if test="@depends">
                <xsl:attribute name="depends">
                    <xsl:value-of select="@depends" />
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@extensionOf and $profile.enabled = 'true'">
                <xsl:attribute name="extensionOf">
                    <xsl:value-of select="@extensionOf" />
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@name = $project.entrypoint and not(starts-with(@name, '-ABC:SDK:'))">
                <xsl:variable name="project.namespace">
                    <xsl:call-template name="string.get.parent">
                        <xsl:with-param name="input" select="substring($project.entrypoint, 2)" />
                        <xsl:with-param name="delimiter" select="':'" />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="/abc/project[@name = concat($project.namespace, ':Common')]">
                    <echoxml file="{$abc.generation.target}"
                             append="true">
                        <xsl:element name="import">
                            <xsl:attribute name="file">
                                <xsl:call-template name="file.from.project.name">
                                    <xsl:with-param name="project.name" select="concat($project.namespace, ':Common')" />
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:element>
                    </echoxml>
                </xsl:if>
                <echoxml file="{$abc.generation.target}"
                         append="true">
                    <xsl:element name="import">
                        <xsl:attribute name="file">
                            <xsl:call-template name="file.from.project.name">
                                <xsl:with-param name="project.name" select="../@name" />
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:element>
                </echoxml>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="/abc/project/extension-point">
        <xsl:copy-of select="." />
    </xsl:template>


    <!--
        Utillity Functions
    -->
    <xsl:template name="profile.from.project.namespace">
        <xsl:param name="project.namespace" />

        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

        <xsl:value-of select="concat(
                'profile.',
                translate(
                    translate(
                        $project.namespace,
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
                '.xml'
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
                        <xsl:call-template name="string.get.parent">
                            <xsl:with-param name="input"
                                            select="$profile.name" />
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="string.get.parent">
        <xsl:param name="input" />
        <xsl:param name="delimiter" select="'.'" />

        <xsl:if test="contains($input, $delimiter)">
            <xsl:value-of select="substring-before($input, $delimiter)" />
            <xsl:if test="contains(substring-after($input, $delimiter), $delimiter)">
                <xsl:value-of select="$delimiter" />
            </xsl:if>
            <xsl:call-template name="string.get.parent">
                <xsl:with-param name="input"
                                select="substring-after($input, $delimiter)" />
                <xsl:with-param name="delimiter" select="$delimiter" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
