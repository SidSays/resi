public with sharing class OffsetIterable implements Iterable<Integer> {

	private Integer chunkSize;
	private Integer totalRecords;

	public OffsetIterable(Integer chunkSize, Integer totalRecords) {
		this.chunkSize = chunkSize;
		this.totalRecords = totalRecords;
	}

	public Iterator<Integer> iterator() {
		return new OffsetIterator(chunkSize,totalRecords);
	}
}