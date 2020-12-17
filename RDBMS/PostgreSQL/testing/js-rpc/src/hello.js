const hello = function({ name, location }){
    const greeting = `Hello ${name} from ${location}`;
    const length = greeting.length;

    const response = { greeting, length};
    return response;
}

module.exports = {
    hello
}
