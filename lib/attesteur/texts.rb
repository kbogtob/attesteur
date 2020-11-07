# frozen_string_literal: true

module Attesteur
  module Texts
    SUBSCRIPTION = "Bonjour ! Je vais vous demander de vous inscrire pour pouvoir vous générer des attestations."

    SLIDE_TO_DM = "C'est ma came les attestations, viens en MP."

    GENERATE = "Générer une attestation pour quelle raison ?"
    REASON_WORK = "Pour travailler 💻"
    REASON_FOOD = "Pour achats de première nécessité 🍖"
    REASON_HEALTH = "Pour raisons médicales 🏥"
    REASON_SPORT = "Pour raisons sportives (1h) ⚽"
    REASON_FAMILY = "Motif impérieux ou familial 👪"
    REASON_PETS = "Promener son chien 🐶"
    REASON_SCHOOL = "Pour emmener les enfants à l'école 👶"

    GENERATING = "Ok je vous génère une attestation..."
    HELP_ME = "Autres options"
    HELP = "Vous pouvez taper /forget pour vous faire oublier."
    FORGETING = "Ok je vous oublie..."
    UNKNOWN = "Je ne vous ai pas compris."

    QUESTIONS = {
      first_name: "Quel est votre prénom ?",
      last_name: "Quel est votre nom de famille ?",
      birth_date: "Quel est votre date de naissance ?",
      birth_place: "Quel est votre lieu de naissance ?",
      town: "Quel est votre ville de résidence ?",
      zipcode: "Quel est votre code postal ?",
      address: "Quel est votre adresse (numéro et rue) ?",
    }.freeze

    class << self
      def question_for(field)
        QUESTIONS[field.to_sym]
      end
    end
  end
end
