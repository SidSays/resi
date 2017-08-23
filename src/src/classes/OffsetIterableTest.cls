@isTest
private class OffsetIterableTest {

	@isTest static void iterator() {
		Test.startTest();
		OffsetIterable offsetParams = new OffsetIterable(1,2);
		System.assert(offsetParams.iterator() instanceof OffsetIterator, 'Failed to construct OffsetIterator from OffsetIterable.');
		Test.stopTest();
	}
}