const hello = function ({ name, location }) {
   const greeting = `Hello ${name} from ${location} `;
   const length = greeting.length;

   const response = { greeting, length };
   return response;
};

const goodbye = function ({ name, location }) {
   const greeting = `Goodbye ${name} from ${location} `;
   const length = greeting.length;

   const response = { greeting, length };
   return response;
};

module.exports = {
   hello,
   goodbye,
};
