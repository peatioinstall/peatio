describe Private::WithdrawsController, type: :controller do
  describe '#create' do
    let(:params) { { withdraw: { currency: :btc, sum: 90.1, destination_id: withdraw_destination.id } } }
    let(:request) { post :create, params.merge(currency: params[:withdraw][:currency]), session }
    let(:session) { { member_id: member.id } }
    let(:withdraw_destination) { create(:coin_withdraw_destination, member: member) }
    let(:member) { create(:member, :verified_identity).tap { |m| m.get_account(:btc).plus_funds(100) } }

    it 'creates withdraw' do
      request
      expect(response).to have_http_status(204)
      withdraw = Withdraw.last
      expect(withdraw.currency.code).to eq params[:withdraw][:currency].to_s
      expect(withdraw.destination).to eq withdraw_destination
      expect(withdraw.sum.to_s).to eq params[:withdraw][:sum].to_s
    end

    context 'extremely precise values' do
      before { Currency.any_instance.stubs(:precision).returns(16) }
      it 'successfully created withdraw and keeps precision for amount' do
        params[:withdraw][:sum] = '56.3923412341353443'
        request
        expect(response).to have_http_status(204)
        expect(Withdraw.last.sum.to_s).to eq params[:withdraw][:sum]
      end
    end
  end
end
