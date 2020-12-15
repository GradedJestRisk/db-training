'use strict';

const Hapi = require('@hapi/hapi');

const init = async () => {

    const server = Hapi.server({
        port: 3000,
        host: 'localhost'
    });

    server.route({
        method: 'GET',
        path: '/',
        handler: (request, h) => {
            console.log(request.info.remoteAddress + ': ' + request.method.toUpperCase() + ' ' + request.path);
            return 'Hello World!';
        }
    });

    server.route({
        method: 'PUT',
        path: '/hello',
        handler: (request, h) => {
            console.log(request.info.remoteAddress + ': ' + request.method.toUpperCase() + ' ' + request.path);
            return { hello : 'world'};
        }
    });

    await server.start();

    console.log('Server running on %s', server.info.uri);
};

process.on('unhandledRejection', (err) => {

    console.log(err);
    process.exit(1);
});

init();
