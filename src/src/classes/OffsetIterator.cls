public with sharing class OffsetIterator implements Iterator<Integer> {

	private Integer[] offsets;
	private Integer index;

	public OffsetIterator(Integer chunkSize, Integer totalRecords) {
		index = 0;
		offsets = new Integer[ (Integer)Math.ceil((Decimal)totalRecords / chunkSize) ];
		for(Integer i = 0; i< offsets.size(); i++) {
			offsets[i] = i * chunkSize;
		}
	}

	public Boolean hasNext() {
		return index < offsets.size();
	}

	public Integer next() {
		index++;
		return offsets[index - 1];
	}
}