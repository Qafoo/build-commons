module.exports = function(grunt) {

    grunt.initConfig({
        jshint: {
            options: {
                jshintrc: 'jshintrc'
            },
            all: ['source/javascript/**/*.js'],
        }
    });

    grunt.loadNpmTasks('grunt-contrib-jshint');

    grunt.registerTask('lint', ['jshint:all']);
    grunt.registerTask('default', ['lint']);
};
