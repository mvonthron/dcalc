import std.stdio;
import std.string;
import std.conv;

import tokenizer;

void parse(char[] line)
{
    if(1) {
    //if(line[0] == '?') {
        writeln("... ", line);
    }
    tokenize(to!string(line));
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