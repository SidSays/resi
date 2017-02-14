@isTest
private class OffsetIteratorTest {

	@isTest static void simpleIteration() {
		Test.startTest();
		OffsetIterator offsets = new OffsetIterator(1,2);
		System.assert(offsets.hasNext(), 'Failed to detect first offset.');
		System.assertEquals(0, offsets.next(), 'First offset should be 0.');
		System.assert(offsets.hasNext(), 'Failed to detect second offset.');
		System.assertEquals(1, offsets.next(), 'Second offset should be 1.');
		System.assert(!offsets.hasNext(), 'Detect extra offset.');
		Test.stopTest();
	}
}