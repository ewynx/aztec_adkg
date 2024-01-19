contract SecretSharing {
    use dep::aztec::{
      context::{PrivateContext, PublicContext, Context},
      state_vars::{map::Map, public_state::PublicState, set::Set, singleton::Singleton},
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

  // Step 1: only public storage
  // Stores the pub keys of other participants & received shares
  struct Storage {
    participants: Map<AztecAddress, PublicState<bool, BOOL_SERIALIZED_LEN>>,
    shares: Map<AztecAddress, PublicState<Field, FIELD_SERIALIZED_LEN>>,
    secret: Singleton<FieldNote, FIELD_NOTE_LEN>, // TODO this is not yet used
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
  fn constructor() {
  }

  #[aztec(public)]
  fn add_node(node: AztecAddress) {
    storage.participants.at(node).write(true)
  }

// TODO this doesn't work, try ImmutableSingleton and assign at construction https://docs.aztec.network/dev_docs/contracts/syntax/storage/main#immutablesingletonnotetype
  // // Create shares for the given secrets and distribute them to the stored participants
  // #[aztec(public)]
  // fn send_shares(secret_var: Singleton<FieldNote, FIELD_NOTE_LEN>, secret: &mut FieldNote) {
  //   // Update the secret
    
    
  //   // This doesn't work, seems to be caused by &mut FieldNote, error:
  //   /* The application panicked (crashed).
  //   Message:  [Aztec Noir] Provided parameter type: MutableReference(UnresolvedType { typ: Named(Path { segments: [Ident(Spanned { contents: "FieldNote", span: Span(Span { start: ByteIndex(2111), end: ByteIndex(2120) }) })], kind: Plain, span: Span(Span { start: ByteIndex(2111), end: ByteIndex(2120) }) }, []), span: Some(Span(Span { start: ByteIndex(2111), end: ByteIndex(2120) })) }) is not supported
  //   Location: aztec_macros/src/lib.rs:669

  //   This is a bug. We may have already fixed this in newer versions of Nargo so try searching for similar issues at https://github.com/noir-lang/noir/issues/.
  //   If there isn't an open issue for this bug, consider opening one at https://github.com/noir-lang/noir/issues/new?labels=bug&template=bug_report.yml
  //   */

  //   secret_var.replace(secret, true);
  //   // TODO Create shares and send them

  // }

  // Placeholder when there are no private state variables
  // https://docs.aztec.network/dev_docs/contracts/syntax/storage/main#storage-struct
  unconstrained fn compute_note_hash_and_nullifier(
        contract_address: AztecAddress,
        nonce: Field,
        storage_slot: Field,
        serialized_note: [Field; 0]
    ) -> pub [Field; 4] {
      [0, 0, 0, 0]
    }
}