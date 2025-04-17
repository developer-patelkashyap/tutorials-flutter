/// Strings

main() {
    // Basic Strings
    var s1 = 'Single quotes work well for string literals.';
    var s2 = "Double quotes work just as well.";
    var s3 = 'It\'s easy to escape the string delimiter.';
    var s4 = "It's even easier to use the other delimiter.";

    print(s1);
    print(s2);
    print(s3);
    print(s4);

    // Raw String
    var s = r'In a raw string, not even \n gets special treatment.';
    print(s);

    // String Interpolation
    var age = 23;
    var str = 'My age is: $age';
    print(str);

    // Multiline Strings
    var multi1 = '''
        You can create
        multi-line strings like this one.
        ''';

    var multi2 = """
        This is also a
        multi-line string.""";

    print(multi1);
    print(multi2);
}
