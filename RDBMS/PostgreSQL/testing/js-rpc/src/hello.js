const hello = function(firstPerson, secondPerson){
    const greeting = `Hello ${firstPerson.name} from ${firstPerson.location} and ${secondPerson.name} from ${secondPerson.location}`;
    const length = greeting.length;

    const response = { greeting, length};
    return response;
}

module.exports = {
    hello
}
