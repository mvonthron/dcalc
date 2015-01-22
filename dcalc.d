import std.stdio;
import std.string;
import std.conv;

import tokenizer;
import group;

void parse(char[] line)
{
    if(1) {
    //if(line[0] == '?') {
        writeln("... ", line);
    }
    auto tokens = tokenize(to!string(line));
    Tokenizer.printTokens(tokens);

    auto groups = groupify(tokens);
    writeln("1.", groups.toString());    

    auto postfix = shunting_yard(tokens);
    Tokenizer.printTokens(postfix);
    //writeln("2.", groups.toString());
}

void main()
{
    writeln("DCalc");
    write("> ");

    foreach (line; stdin.byLine()) {
        parse(line);
        write("> ");
    }

}