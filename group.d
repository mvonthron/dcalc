import std.stdio;
import std.string;
import std.container;
import tokenizer;


class Group: Token
{
    this(Token left, Operator op, Token right)
    {
        this.left = left;
        this.op = op;
        this.right = right;
    }

    override string toString()
    {
        return format("(%s %s %s)", left.toString(), op.toString(), right.toString());
    }

    static Group fromPostfix(Token[] tokens)
    {
        Array!Token stack;
        foreach(token; tokens){
            Operator operator = cast(Operator) token;
            if (operator){
                auto right = stack.back;
                stack.removeBack();
                auto left = stack.back;
                stack.removeBack();
                
                stack.insertBack(new Group(left, operator, right));

            }else{
                stack.insertBack(token);
            }   
        }
        return cast(Group) stack.back;
    }

    static void exec(Token[] tokens)
    {
        Array!Number stack;
    
        foreach(token; tokens){
            writeln("stack len ", stack.length);

            Operator operator = cast(Operator) token;
            if (operator){
                if(operator.value == '(' || operator.value == ')'){
                    writeln("Error: shouldn't be any parenthesis in the postfix form");
                    break;
                }
                auto right = stack.back;
                stack.removeBack();
                auto left = stack.back;
                stack.removeBack();
                
                operator.op(left, right);

            }else{
                stack.insertBack(cast(Number) token);
            }   
        }
    }

    Token left;
    Operator op;
    Token right;
}

Token[] shunting_yard(Token[] infix)
{
    Token[] postfix;
    Array!Operator operators;

    foreach(token; infix) {
        Operator operator = cast(Operator) token;

        if(operator){
            if(operators.empty || operator.value == '('){
                operators.insertBack(operator);
            }
            else if(operator.value == ')') {
                while(!operators.empty && operators.back.value != '(') {
                    postfix ~= operators.back;
                    operators.removeBack();
                }
                // we break the loop not to go infinite but there must be a left parenthesis somewhere
                assert(!operators.empty && operators.back.value == '(');
                // and discard the right parenthesis
                operators.removeBack();
            }
            else{
                while(!operators.empty) {
                    if(operator.assoc == Associativity.Left && operator.priority <= operators.back.priority
                        || operator.assoc == Associativity.Right && operator.priority < operators.back.priority) {
                        postfix ~= operators.back;
                        operators.removeBack();
                    }else{
                        break;
                    }
                }

                operators.insertBack(operator);
            }

        }else{
            postfix ~= token;
        }
    }

    while(!operators.empty){
        postfix ~= operators.back;
        operators.removeBack();
    }

    return postfix;
}


string postfix_tostring(Token[] tokens)
{
    Array!Token stack;
    
    foreach(token; tokens){
        Operator operator = cast(Operator) token;
        if (operator){
            if(operator.value == '(' || operator.value == ')'){
                writeln("Error: shouldn't be any parenthesis in the postfix form");
                break;
            }
            auto right = stack.back;
            stack.removeBack();
            auto left = stack.back;
            stack.removeBack();
            
            stack.insertBack(new Group(left, operator, right));

        }else{
            stack.insertBack(token);
        }   
    }
    
    return stack.back.toString();
}

unittest 
{

}