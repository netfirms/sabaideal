module Komplex
  module Admin
    class MessagesController < ApplicationController
      before_action :set_conversation, only: [:create]
      before_action :set_message, only: [:show, :edit, :update, :destroy, :mark_as_read, :mark_as_unread]

      def show
      end

      def new
        @message = Komplex::Message.new
      end

      def edit
      end

      def create
        @message = Komplex::Message.new(message_params)
        @message.conversation = @conversation
        @message.sender = current_spree_user

        if @message.save
          redirect_to admin_conversation_path(@conversation), notice: 'Message was successfully sent.'
        else
          @messages = @conversation.messages.order(created_at: :asc)
          render 'komplex/admin/conversations/show'
        end
      end

      def update
        if @message.update(message_params)
          redirect_to admin_message_path(@message), notice: 'Message was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        conversation = @message.conversation
        @message.destroy
        redirect_to admin_conversation_path(conversation), notice: 'Message was successfully destroyed.'
      end

      def mark_as_read
        @message.mark_as_read!
        redirect_to admin_conversation_path(@message.conversation), notice: 'Message was marked as read.'
      end

      def mark_as_unread
        @message.mark_as_unread!
        redirect_to admin_conversation_path(@message.conversation), notice: 'Message was marked as unread.'
      end

      private

      def set_conversation
        @conversation = Komplex::Conversation.find(params[:conversation_id])
      end

      def set_message
        @message = Komplex::Message.find(params[:id])
      end

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end