contract SecretSharing {
  use dep::aztec::{
    note::{
      note_header::NoteHeader,
      utils as note_utils,
    },
    context::{PrivateContext, PublicContext, Context},
    state_vars::{immutable_singleton::ImmutableSingleton, map::Map, public_state::PublicState, set::Set, singleton::Singleton},
    types::type_serialization::{
      field_serialization::{FieldSerializationMethods, FIELD_SERIALIZED_LEN},
      bool_serialization::{BoolSerializationMethods, BOOL_SERIALIZED_LEN},
      address_serialization::{AddressSerializationMethods, AZTEC_ADDRESS_SERIALIZED_LEN}
    }
  };
  use dep::aztec::protocol_types::{
    abis::function_selector::FunctionSelector,
    address::AztecAddress,
  };
  use dep::field_note::field_note::{FieldNote, FieldNoteMethods, FIELD_NOTE_LEN};

  struct Storage {
    participants: Map<AztecAddress, PublicState<bool, BOOL_SERIALIZED_LEN>>,
    shares: Map<AztecAddress, PublicState<Field, FIELD_SERIALIZED_LEN>>,
    secret: Singleton<FieldNote, FIELD_NOTE_LEN>,
  }

  impl Storage {
    fn init(context: Context) -> Self {
        Storage {
            participants: Map::new(context,1, |context, slot| {
                        PublicState::new(
                            context,
                            slot,
                            BoolSerializationMethods,
                        )
                    },
            ),
            shares: Map::new(context, 2, |context, slot| {
                        PublicState::new(
                            context,
                            slot,
                            FieldSerializationMethods,
                        )
                    },
            ),
            secret: Singleton::new(context, 3, FieldNoteMethods)
        }
    }
  }

  #[aztec(private)]
  fn constructor(secret: Field) {
    let mut secret_note = FieldNote::new(secret);
    storage.secret.initialize(&mut secret_note, Option::none(), true);
  }

  #[aztec(public)]
  fn add_node(node: AztecAddress) {
    storage.participants.at(node).write(true)
  }

// TODO fixme - how to implement this correctly?
  //   #[aztec(public)]
  // fn replace_secret(secret: &mut FieldNote) {
  //       storage.secret.replace(secret, true);
  //   }

  unconstrained fn compute_note_hash_and_nullifier(
    contract_address: AztecAddress,
    nonce: Field,
    storage_slot: Field,
    serialized_note: [Field; FIELD_NOTE_LEN]
  ) -> pub [Field; 4] {
    let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
    note_utils::compute_note_hash_and_nullifier(FieldNoteMethods, note_header, serialized_note)
  }
}
