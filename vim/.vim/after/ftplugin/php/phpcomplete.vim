" vi: et fdm=marker sts=4 sw=4 ts=4
" TODO Laravel TestCase additions
if !exists('g:php_builtin_classes')
    " create the global dictionary so we can inject stuff into it
    call phpcomplete#LoadData()
endif

if exists('did_load_phpcomplete_overrides')
    finish
endif
let did_load_phpcomplete_overrides = 1

let s:include_deprecated_methods = 0
let s:include_old_phpunit_class_names = 1

" Dictionary of proper class basename => namespace
let s:alt_testcase_classes = {
            \ 'PHPUnit_Framework_TestCase': '',
            \ }

" s:methods_assert {{{
" From PHPUnit\Framework\Assert
let s:methods_assert = {
            \ 'assertArrayHasKey': {
            \   'signature': 'int | string $key, array | \ArrayAccess $array [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertArrayNotHasKey': {
            \   'signature': 'int | string $key, array | \ArrayAccess $array [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertContains': {
            \   'signature': '$needle, $haystack [, string $message = '''' [, bool $ignoreCase = false [, bool $checkForObjectIdentity = true [, bool $checkForNonObjectIdentity = false]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertContainsEquals': {
            \   'signature': '$needle, iterable $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotContains': {
            \   'signature': '$needle, $haystack [, string $message = '''' [, bool $ignoreCase = false [, bool $checkForObjectIdentity = true [, bool $checkForNonObjectIdentity = false]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertNotContainsEquals': {
            \   'signature': '$needle, iterable $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertContainsOnly': {
            \   'signature': 'string $type, iterable $haystack [, bool $isNativeType = null [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'assertContainsOnlyInstancesOf': {
            \   'signature': 'string $className, iterable $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotContainsOnly': {
            \   'signature': 'string $type, iterable $haystack [, bool $isNativeType = null [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'assertCount': {
            \   'signature': 'int $expectedCount, \Countable | iterable $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotCount': {
            \   'signature': 'int $expectedCount, \Countable | iterable $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertEquals': {
            \   'signature': '$expected, $actual [, string $message = '''' [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertEqualsCanonicalizing': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertEqualsIgnoringCase': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertEqualsWithDelta': {
            \   'signature': '$expected, $actual, float $delta [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotEquals': {
            \   'signature': '$expected, $actual [, string $message = '''' [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertNotEqualsCanonicalizing': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotEqualsIgnoringCase': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotEqualsWithDelta': {
            \   'signature': '$expected, $actual, float $delta [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertEmpty': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotEmpty': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertGreaterThan': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertGreaterThanOrEqual': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertLessThan': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertLessThanOrEqual': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileEquals': {
            \   'signature': 'string $expected, string $actual [, string $message = '''' [, bool $canonicalize = false [, bool $ignoreCase = false]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertFileNotEquals': {
            \   'signature': 'string $expected, string $actual [, string $message = '''' [, bool $canonicalize = false [, bool $ignoreCase = false]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertStringEqualsFile': {
            \   'signature': 'string $expectedFile, string $actualString [, string $message = '''' [, bool $canonicalize = false [, bool $ignoreCase = false]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertStringNotEqualsFile': {
            \   'signature': 'string $expectedFile, string $actualString [, string $message = '''' [, bool $canonicalize = false [, bool $ignoreCase = false]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertIsReadable': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotIsReadable': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsWritable': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotIsWritable': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryExists': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryNotExists': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryIsReadable': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryNotIsReadable': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryIsWritable': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertDirectoryNotIsWritable': {
            \   'signature': 'string $directory [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileExists': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileNotExists': {
            \   'signature': 'string $filename [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileIsReadable': {
            \   'signature': 'string $file [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileNotIsReadable': {
            \   'signature': 'string $file [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileIsWritable': {
            \   'signature': 'string $file [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFileNotIsWritable': {
            \   'signature': 'string $file [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertTrue': {
            \   'signature': '$condition [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotTrue': {
            \   'signature': '$condition [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFalse': {
            \   'signature': '$condition [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotFalse': {
            \   'signature': '$condition [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNull': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotNull': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertFinite': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertInfinite': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNan': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertClassHasAttribute': {
            \   'signature': 'string $attributeName, string $className [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertClassNotHasAttribute': {
            \   'signature': 'string $attributeName, string $className [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertClassHasStaticAttribute': {
            \   'signature': 'string $attributeName, string $className [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertClassNotHasStaticAttribute': {
            \   'signature': 'string $attributeName, string $className [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertObjectHasAttribute': {
            \   'signature': 'string $attributeName, object $object [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertObjectNotHasAttribute': {
            \   'signature': 'string $attributeName, object $object [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertSame': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotSame': {
            \   'signature': '$expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertInstanceOf': {
            \   'signature': 'string $expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotInstanceOf': {
            \   'signature': 'string $expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsArray': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsBool': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsFloat': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsInt': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNumeric': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsObject': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsResource': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsString': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsScalar': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsCallable': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsIterable': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotInternalType': {
            \   'signature': 'string $expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotArray': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotBool': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotFloat': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotInt': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotNumeric': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotObject': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotResource': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotString': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotScalar': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotCallable': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertIsNotIterable': {
            \   'signature': '$actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertRegExp': {
            \   'signature': 'string $pattern, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotRegExp': {
            \   'signature': 'string $pattern, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertSameSize': {
            \   'signature': '\Countable | iterable $expected, \Countable | iterable $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertNotSameSize': {
            \   'signature': '\Countable | iterable $expected, \Countable | iterable $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringMatchesFormat': {
            \   'signature': 'string $format, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringNotMatchesFormat': {
            \   'signature': 'string $format, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringMatchesFormatFile': {
            \   'signature': 'string $formatFile, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringNotMatchesFormatFile': {
            \   'signature': 'string $formatFile, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringStartsWith': {
            \   'signature': 'string $prefix, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringStartsNotWith': {
            \   'signature': 'string $prefix, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringContainsString': {
            \   'signature': 'string $needle, string $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringContainsStringIgnoringCase': {
            \   'signature': 'string $needle, string $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringNotContainsString': {
            \   'signature': 'string $needle, string $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringNotContainsStringIgnoringCase': {
            \   'signature': 'string $needle, string $haystack [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringEndsWith': {
            \   'signature': 'string $suffix, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertStringEndsNotWith': {
            \   'signature': 'string $suffix, string $string [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlFileEqualsXmlFile': {
            \   'signature': 'string $expectedFile, string $actualFile [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlFileNotEqualsXmlFile': {
            \   'signature': 'string $expectedFile, string $actualFile [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlStringEqualsXmlFile': {
            \   'signature': 'string $expectedFile, \DOMDocument | string $actualXml [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlStringNotEqualsXmlFile': {
            \   'signature': 'string $expectedFile, \DOMDocument | string $actualXml [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlStringEqualsXmlString': {
            \   'signature': '\DOMDocument | string $expectedXml, \DOMDocument | string $actualXml [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertXmlStringNotEqualsXmlString': {
            \   'signature': '\DOMDocument | string $expectedXml, \DOMDocument | string $actualXml [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertEqualXMLStructure': {
            \   'signature': '\DOMElement $expectedElement, \DOMElement $actualElement [, bool $checkAttributes = false [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'assertThat': {
            \   'signature': '$value, \PHPUnit\Framework\Constraint\Constraint $constraint [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJson': {
            \   'signature': 'string $actualJson [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonStringEqualsJsonString': {
            \   'signature': 'string $expectedJson, string $actualJson [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonStringNotEqualsJsonString': {
            \   'signature': 'string $expectedJson, string $actualJson [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonStringEqualsJsonFile': {
            \   'signature': 'string $expectedFile, string $actualJson [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonStringNotEqualsJsonFile': {
            \   'signature': 'string $expectedFile, string $actualJson [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonFileEqualsJsonFile': {
            \   'signature': 'string $expectedFile, string $actualFile [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertJsonFileNotEqualsJsonFile': {
            \   'signature': 'string $expectedFile, string $actualFile [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'logicalAnd': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalAnd',
            \ },
            \ 'logicalOr': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalOr',
            \ },
            \ 'logicalNot': {
            \   'signature': '\PHPUnit\Framework\Constraint\Constraint $constraint',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalNot',
            \ },
            \ 'logicalXor': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalXor',
            \ },
            \ 'anything': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsAnything',
            \ },
            \ 'isTrue': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsTrue',
            \ },
            \ 'callback': {
            \   'signature': 'callable $callback',
            \   'return_type': '\PHPUnit\Framework\Constraint\Callback',
            \ },
            \ 'isFalse': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsFalse',
            \ },
            \ 'isJson': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsJson',
            \ },
            \ 'isNull': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsNull',
            \ },
            \ 'isFinite': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsFinite',
            \ },
            \ 'isInfinite': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsInfinite',
            \ },
            \ 'isNan': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsNan',
            \ },
            \ 'contains': {
            \   'signature': '$value [, bool $checkForObjectIdentity = true [, bool $checkForNonObjectIdentity = false]]',
            \   'return_type': '\PHPUnit\Framework\Constraint\TraversableContains',
            \ },
            \ 'containsOnly': {
            \   'signature': 'string $type',
            \   'return_type': '\PHPUnit\Framework\Constraint\TraversableContainsOnly',
            \ },
            \ 'containsOnlyInstancesOf': {
            \   'signature': 'string $className',
            \   'return_type': '\PHPUnit\Framework\Constraint\TraversableContainsOnly',
            \ },
            \ 'arrayHasKey': {
            \   'signature': 'int | string $key',
            \   'return_type': '\PHPUnit\Framework\Constraint\ArrayHasKey',
            \ },
            \ 'equalTo': {
            \   'signature': '$value [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsEqual',
            \ },
            \ 'isEmpty': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsEmpty',
            \ },
            \ 'isWritable': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsWritable',
            \ },
            \ 'isReadable': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsReadable',
            \ },
            \ 'directoryExists': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\DirectoryExists',
            \ },
            \ 'fileExists': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\Constraint\FileExists',
            \ },
            \ 'greaterThan': {
            \   'signature': '$value',
            \   'return_type': '\PHPUnit\Framework\Constraint\GreaterThan',
            \ },
            \ 'greaterThanOrEqual': {
            \   'signature': '$value',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalOr',
            \ },
            \ 'classHasAttribute': {
            \   'signature': 'string $attributeName',
            \   'return_type': '\PHPUnit\Framework\Constraint\ClassHasAttribute',
            \ },
            \ 'classHasStaticAttribute': {
            \   'signature': 'string $attributeName',
            \   'return_type': '\PHPUnit\Framework\Constraint\ClassHasStaticAttribute',
            \ },
            \ 'objectHasAttribute': {
            \   'signature': '$attributeName',
            \   'return_type': '\PHPUnit\Framework\Constraint\ObjectHasAttribute',
            \ },
            \ 'identicalTo': {
            \   'signature': '$value',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsIdentical',
            \ },
            \ 'isInstanceOf': {
            \   'signature': 'string $className',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsInstanceOf',
            \ },
            \ 'isType': {
            \   'signature': 'string $type',
            \   'return_type': '\PHPUnit\Framework\Constraint\IsType',
            \ },
            \ 'lessThan': {
            \   'signature': '$value',
            \   'return_type': '\PHPUnit\Framework\Constraint\LessThan',
            \ },
            \ 'lessThanOrEqual': {
            \   'signature': '$value',
            \   'return_type': '\PHPUnit\Framework\Constraint\LogicalOr',
            \ },
            \ 'matchesRegularExpression': {
            \   'signature': 'string $pattern',
            \   'return_type': '\PHPUnit\Framework\Constraint\RegularExpression',
            \ },
            \ 'matches': {
            \   'signature': 'string $string',
            \   'return_type': '\PHPUnit\Framework\Constraint\StringMatchesFormatDescription',
            \ },
            \ 'stringStartsWith': {
            \   'signature': '$prefix',
            \   'return_type': '\PHPUnit\Framework\Constraint\StringStartsWith',
            \ },
            \ 'stringContains': {
            \   'signature': 'string $string [, bool $case = true]',
            \   'return_type': '\PHPUnit\Framework\Constraint\StringContains',
            \ },
            \ 'stringEndsWith': {
            \   'signature': 'string $suffix',
            \   'return_type': '\PHPUnit\Framework\Constraint\StringEndsWith',
            \ },
            \ 'countOf': {
            \   'signature': 'int $count',
            \   'return_type': '\PHPUnit\Framework\Constraint\Count',
            \ },
            \ 'fail': {
            \   'signature': '[string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'markTestIncomplete': {
            \   'signature': '[string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'markTestSkipped': {
            \   'signature': '[string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'getCount': {
            \   'signature': 'void',
            \   'return_type': 'int',
            \ },
            \ 'resetCount': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ }

if s:include_deprecated_methods > 0
    let methods_assert_deprecated = {
            \ 'assertArraySubset': {
            \   'signature': 'array | \ArrayAccess $subset, array | \ArrayAccess $array [, bool $checkForObjectIdentity = false [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'attributeEqualTo': {
            \   'signature': 'string $attributeName, $value [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]',
            \   'return_type': '\PHPUnit\Framework\Constraint\Attribute',
            \ },
            \ 'assertAttributeContains': {
            \   'signature': '$needle, string $haystackAttributeName, object | string $haystackClassOrObject [, string $message = '''' [, bool $ignoreCase = false [, bool $checkForObjectIdentity = true [, bool $checkForNonObjectIdentity = false]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotContains': {
            \   'signature': '$needle, string $haystackAttributeName, object | string $haystackClassOrObject [, string $message [, bool $ignoreCase = false [, bool $checkForObjectIdentity = true [, bool $checkForNonObjectIdentity = false]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeContainsOnly': {
            \   'signature': 'string $type, string $haystackAttributeName, object | string $haystackClassOrObject [, bool $isNativeType = null [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotContainsOnly': {
            \   'signature': 'string $type, string $haystackAttributeName, object | string $haystackClassOrObject [, bool $isNativeType = null [, string $message = '''']]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeCount': {
            \   'signature': 'int $expectedCount, string $haystackAttributeName, object | string $haystackClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotCount': {
            \   'signature': 'int $expectedCount, string $haystackAttributeName, object | string $haystackClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeEquals': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''' [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotEquals': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''' [, float $delta = 0.0 [, int $maxDepth = 10 [, bool $canonicalize = false [, bool $ignoreCase = false]]]]]',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeEmpty': {
            \   'signature': 'string $haystackAttributeName, object | string $haystackClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotEmpty': {
            \   'signature': 'string $haystackAttributeName, object | string $haystackClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeGreaterThan': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeGreaterThanOrEqual': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeLessThan': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeLessThanOrEqual': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeSame': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotSame': {
            \   'signature': '$expected, string $actualAttributeName, object | string $actualClassOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeInstanceOf': {
            \   'signature': 'string $expected, string $attributeName, $classOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotInstanceOf': {
            \   'signature': 'string $expected, string $attributeName, $classOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertInternalType': {
            \   'signature': 'string $expected, $actual [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeInternalType': {
            \   'signature': 'string $expected, string $attributeName, object | string $classOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'assertAttributeNotInternalType': {
            \   'signature': 'string $expected, string $attributeName, object | string $classOrObject [, string $message = '''']',
            \   'return_type': 'void',
            \ },
            \ 'attribute': {
            \   'signature': '\PHPUnit\Framework\Constraint\Constraint $constraint, string $attributeName',
            \   'return_type': '\PHPUnit\Framework\Constraint\Attribute',
            \ },
            \ }
    call extend(methods_assert, methods_assert_deprecated)
endif
" s:methods_assert }}}

" s:methods_testcase {{{
" From PHPUnit\Framework\TestCase
let s:methods_testcase = {
            \ 'getMockBuilder': {
            \   'signature': 'string $className',
            \   'return_type': '\PHPUnit\Framework\MockObject\MockBuilder',
            \ },
            \ 'setBackupGlobals': {
            \   'signature': 'bool $backupGlobals | void',
            \   'return_type': 'void',
            \ },
            \ 'setBackupStaticAttributes': {
            \   'signature': '?bool $backupStaticAttributes',
            \   'return_type': 'void',
            \ },
            \ 'setRunTestInSeparateProcess': {
            \   'signature': 'bool $runTestInSeparateProcess',
            \   'return_type': 'void',
            \ },
            \ 'setRunClassInSeparateProcess': {
            \   'signature': 'bool $runClassInSeparateProcess',
            \   'return_type': 'void',
            \ },
            \ 'setPreserveGlobalState': {
            \   'signature': 'bool $preserveGlobalState',
            \   'return_type': 'void',
            \ },
            \ 'setInIsolation': {
            \   'signature': 'bool $inIsolation',
            \   'return_type': 'void',
            \ },
            \ 'isInIsolation': {
            \   'signature': 'void',
            \   'return_type': 'bool',
            \ },
            \ 'setOutputCallback': {
            \   'signature': 'callable $callback',
            \   'return_type': 'void',
            \ },
            \ 'setUp': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'tearDown': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'expectException': {
            \   'signature': 'string $exception',
            \   'return_type': 'void',
            \ },
            \ 'expectExceptionCode': {
            \   'signature': 'int|string $code',
            \   'return_type': 'void',
            \ },
            \ 'expectExceptionMessage': {
            \   'signature': 'string $code',
            \   'return_type': 'void',
            \ },
            \ 'expectExceptionMessageRegExp': {
            \   'signature': 'string $messageRegExp',
            \   'return_type': 'void',
            \ },
            \ 'expectExceptionObject': {
            \   'signature': '\Exception $exception',
            \   'return_type': 'void',
            \ },
            \ 'expectNotToPerformAssertions': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'expectOutputRegex': {
            \   'signature': 'string $expectedRegex',
            \   'return_type': 'void',
            \ },
            \ 'expectOutputString': {
            \   'signature': 'string $expectedString',
            \   'return_type': 'void',
            \ },
            \ 'getActualOutputForAssertion': {
            \   'signature': 'void',
            \   'return_type': 'string',
            \ },
            \ 'markAsRisky': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'getStatus': {
            \   'signature': 'void',
            \   'return_type': 'int',
            \ },
            \ 'getStatusMessage': {
            \   'signature': 'void',
            \   'return_type': 'string',
            \ },
            \ 'hasFailed': {
            \   'signature': 'void',
            \   'return_type': 'bool',
            \ },
            \ }

" s:methods_testcase_static {{{
let s:methods_testcase_static = {
            \ 'setUpBeforeClass': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'tearDownAfterClass': {
            \   'signature': 'void',
            \   'return_type': 'void',
            \ },
            \ 'returnCallback': {
            \   'signature': 'callable $callback',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\ReturnCallback',
            \ },
            \ 'returnArgument': {
            \   'signature': 'int $argumentIndex',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\ReturnArgument',
            \ },
            \ 'returnValueMap': {
            \   'signature': 'array $valueMap',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\ReturnValueMap',
            \ },
            \ 'returnSelf': {
            \   'signature': 'void',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\ReturnSelf',
            \ },
            \ 'throwException': {
            \   'signature': '\Throwable $exception',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\Exception',
            \ },
            \ 'onConsecutiveCalls': {
            \   'signature': '...$args',
            \   'return_type': '\PHPUnit\Framework\MockObject\Stub\ConsecutiveCalls',
            \ },
            \ }
" s:methods_testcase_static }}}

" combine the methods, or phpcomplete won't omnicomplete on
" $this->assert... >:-[]
call extend(s:methods_testcase, s:methods_testcase_static)
" s:methods_testcase }}}

call extend(s:methods_testcase, s:methods_assert)

" Note: This is a hack!
" It's indexed by 'testcase' in order to fool phpcomplete.vim into thinking
" this is a built-in class. If you use the following syntax it should work:
"
" use PHPUnit\Framework\TestCase;
" class MyTest extends TestCase {
let s:php_builtin_classes_adds = {
            \ 'phpunit': {
            \   'testcase': {
            \     'namespace': 'PHPUnit\Framework',
            \     'name': 'PHPUnit\Framework\TestCase',
            \     'methods': s:methods_testcase,
            \   },
            \ },
            \ }

if exists('s:alt_testcase_classes')
    for [s:classname, s:namespace] in items(s:alt_testcase_classes)
        let s:php_builtin_classes_adds['phpunit'][tolower(s:classname)] = {
                \   'namespace': s:namespace,
                \   'name': s:classname,
                \   'methods': s:methods_testcase,
                \ }
    endfor
endif

for [ext, data] in items(s:php_builtin_classes_adds)
    call extend(g:php_builtin_classes, data)
endfor
