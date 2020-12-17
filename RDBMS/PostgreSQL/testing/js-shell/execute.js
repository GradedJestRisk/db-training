#!/usr/bin/env node
const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage');

const optionDefinitions = [
   { name: 'function', type: String },
   { name: 'name', type: String },
   { name: 'location', type: String },
];

const usageGuideTemplate = [
   {
      header: 'JS function wrapper in shell',
      content: 'Execute any JS function without require()',
   },
   {
      header: 'Usage',
      optionList: [
         {
            name: 'function',
            typeLabel: '{underline name}',
            description: 'The function to be executed.',
         },
         {
            name: 'argument',
            typeLabel: '{underline value}',
            description: 'An argument with a value',
         },
      ],
   },
   {
      header: 'Examples',
      content: [
         {
            desc: '1. No argument call ',
            example: '$ ./execute --function hello',
         },
         {
            desc: '2. Single argument call ',
            example: '$ ./execute --function hello --name john',
         },
         {
            desc: '3. Multiple argument call ',
            example: '$ ./execute --function hello --name john --location nebraska',
         },
      ],
   },
   {
      content: 'Intended to be used with PostgreSQL extension PL/sh {underline https://github.com/petere/plsh}',
   },
];

const options = commandLineArgs(optionDefinitions);
// console.dir(options);

if (options.function === null) {
   const usageGuide = commandLineUsage(usageGuideTemplate);
   console.log(usageGuide);
}

const hello = function ({ name, location }) {
   const greeting = `Hello ${name} from ${location} !`;
   console.log(greeting);
};

const goodbye = function ({ name, location }) {
   const greeting = `Goodbye ${name} from ${location} !`;
   console.log(greeting);
};

if (options.function === 'hello') {
   hello({ name: options.name, location: options.location });
}

if (options.function === 'goodbye') {
   goodbye({ name: options.name, location: options.location });
}
