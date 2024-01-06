RSpec.describe Registration, type: :model do
  describe 'instance_methods' do
    describe '#trim_params' do
      it 'removes extra spaces from the request params' do
        params = {
          first_name: '  Jason  ',
          middle_name: '  Sung  ',
          last_name: '  Choi  ',
          email: ' test@google.com ',
          phone_number: ' 512-222-2223 ',
          color: ' #e54555'
        }

        expect(user.trim_params(params)).to eq(
          first_name: 'Jason',
          middle_name: 'Sung',
          last_name: 'Choi',
          email: 'test@google.com',
          phone_number: '512-222-2223',
          color: '#e54555'
        )
      end
    end
  end
end
