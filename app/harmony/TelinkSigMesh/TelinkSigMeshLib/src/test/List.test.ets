import EncipherTest from './Encipher.test'
import localUnitTest from './LocalUnit.test';
import BlobBlockStatusMessage from './BlobBlockStatusMessage.test';

export default function testsuite() {
  localUnitTest();
  BlobBlockStatusMessage();
}