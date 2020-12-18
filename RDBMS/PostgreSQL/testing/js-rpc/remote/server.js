'use strict';

const Hapi = require('@hapi/hapi');
const Joi = require('@hapi/joi');
const Boom = require('@hapi/boom');

const functions = require('./src/functions');

const init = async () => {
   const defaultPort = 3000;
   const port = parseInt(process.env.PORT, 10) || defaultPort;

   const server = Hapi.server({
      port,
   });

   server.route({
      method: 'GET',
      path: '/',
      handler: (request, h) => {
         console.log(request.info.remoteAddress + ': ' + request.method.toUpperCase() + ' ' + request.path);
         return 'Hello World!';
      },
   });

   server.route({
      method: 'PUT',
      path: '/{function}',
      config: {
         validate: {
            params: Joi.object({
               function: Joi.string().required(),
            }),
            payload: Joi.object({
               name: Joi.string().required(),
               location: Joi.string().required(),
            }),
            failAction: async (request, h, err) => {
               throw Boom.badRequest('Invalid request: ' + err.message);
            },
         },
      },
      handler: (request, h) => {
         const functionName = request.params.function;

         if (functionName === 'hello') {
            return functions.hello({ name: request.payload.name, location: request.payload.location });
         } else if (functionName === 'goodbye') {
            return functions.goodbye({ name: request.payload.name, location: request.payload.location });
         } else {
            throw Boom.notFound(`Function ${functionName} not found`);
         }
      },
   });

   await server.start();

   console.log('Server running on %s', server.info.uri);
};

process.on('unhandledRejection', (err) => {
   console.log(err);
   process.exit(1);
});

init();
